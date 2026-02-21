from usearch.index import Index
from sentence_transformers import CrossEncoder, SentenceTransformer
import sqlite3
import numpy as np
import os
from ucall.rich_posix import Server


class AI:
    def __init__(self) -> None:
        self.reranker = CrossEncoder("cross-encoder/ms-marco-MiniLM-L-6-v2")
        self.encoder = SentenceTransformer("all-MiniLM-L6-v2")

    def rerank(self, query: str, chunks: list[str]):
        # 2. Predict scores (Higher score = More relevant)
        # Cross-encoders take pairs of [query, doc]
        pairs = [[query, chunk] for chunk in chunks]
        scores = self.reranker.predict(pairs)

        # 3. Sort documents by their new scores
        reranked_results = sorted(zip(scores, chunks), key=lambda x: x[0], reverse=True)

        return reranked_results

    def embed(self, sentences: list[str]):
        return self.encoder.encode(sentences)


class RAGStore:
    ai: AI
    db: sqlite3.Connection
    index: Index

    def __init__(self, ai: AI, prefix="rag") -> None:
        self.ai = ai
        self.db = sqlite3.connect(f"{prefix}-meta.db")

        ndim = self.ai.embed(["This is a test sentence."]).shape[1]
        self.index = Index(
            ndim=ndim,  # Define the number of dimensions in input vectors
            metric="cos",  # Choose 'l2sq', 'ip', 'haversine' or other metric, default = 'cos'
            dtype="bf16",  # Store as 'f64', 'f32', 'f16', 'i8', 'b1'..., default = None
            connectivity=16,  # Optional: Limit number of neighbors per graph node
            expansion_add=128,  # Optional: Control the recall of indexing
            expansion_search=64,  # Optional: Control the quality of the search
            multi=False,  # Optional: Allow multiple vectors per key, default = False
        )
        self.index_path = f"{prefix}-usearch.db"
        if os.path.isfile(self.index_path):
            self.index.load(self.index_path)

    def close(self):
        self.db.commit()
        self.db.close()
        self.index.save(self.index_path)

    def add(self, memories: list[str]):
        placeholders = ", ".join(["(?)"] * len(memories))
        cursor = self.db.cursor()
        cursor.execute(
            f"insert into memory (content) values {placeholders} on conflict do nothing returning id",
            tuple(memories),
        )
        new_ids = np.array([row[0] for row in cursor.fetchall()])
        self.db.commit()

        print("new memories:", new_ids)
        embeddings = self.ai.embed(memories)
        self.index.add(new_ids, embeddings)

    def rag(self, query: str) -> list[tuple[float, str]]:
        print("query:", query)

        query_embed = self.ai.embed([query])[0]
        matches = self.index.search(query_embed, 256)

        placeholders = ", ".join(["?"] * len(matches))
        cursor = self.db.cursor()
        cursor.execute(
            f"select content from memory where id in ({placeholders})",
            tuple([int(match.key) for match in matches]),
        )
        memory_rows: list[tuple] = cursor.fetchall()
        results = [row[0] for row in memory_rows]

        return self.ai.rerank(query, results)


ai = AI()
store = RAGStore(ai)
server = Server(port=6567)


@server
def rag_query(query: str, threshold: float = 0) -> dict:
    results = store.rag(query)
    scores = [float(score) for score, _ in results if score >= threshold]
    texts = [text for score, text in results if score >= threshold]
    return {
        "scores": scores,
        "text": texts,
    }


@server
def rag_add(memory: str) -> None:
    store.add([memory])


if __name__ == "__main__":
    try:
        server.run()
    except KeyboardInterrupt:
        print("closing...")
        store.close()
