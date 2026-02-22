use mod.nu

"berlin is the capital of germany" | mod add
"python is a programming language" | mod add
let second_stage = "reranking is often the second stage of modern RAG" | mod add
let rerank_method = "you can use python transformers libraries to do reranking" | mod add
let rerank_def = "reranking is the process of using a small model to score the relevance of RAG results with the user's query" | mod add
let rerank_ml_def = "reranking is a part of machine learning" | mod add
let ml_def = "machine learning is the process of automatically deriving abstractions from data" | mod add

mod relate $second_stage $rerank_def --type extends
mod relate $rerank_method $rerank_def --type extends
mod relate $rerank_def $rerank_ml_def --type extends
mod relate $rerank_ml_def $ml_def --type extends

let info_results = mod info $rerank_def
let query_results = "how do you do reranking?" | mod query --threshold 0.0

{
	info_results: $info_results
	query_results: $query_results
}

