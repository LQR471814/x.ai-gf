let script_dir = $env.FILE_PWD

export def "query" [--threshold: float]: string -> table<score: float text: string> {
	let query = $in
	let t: float = $threshold | default 0.0
	do {
		cd $script_dir
		let results = uv run ucall rag_query --uri=localhost --port=6567 $"query='($query)'" $"threshold=($t)"
			| complete
			| $in.stdout
			| from json
			| get result
		$results.scores
			| enumerate
			| insert text {|i| $results.text | get $i.index}
			| select item text
			| rename score text
	}
}

export def "add" []: string -> nothing {
	let memory = $in
	do {
		cd $script_dir
		uv run ucall rag_add --uri=localhost --port=6567 --positional $memory
			| complete
	}
}

"berlin is the capital of germany" | add
"reranking is the second stage of modern RAG" | add
"you can use reranking to do a range of NLP tasks" | add
"you can use transformers for reranking" | add

"how to do reranking" | query
