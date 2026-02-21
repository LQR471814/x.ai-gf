def ucall [method: string, ...params: string]: nothing -> record {
	do {
		cd $env.FILE_PWD
		let call_result = uv run ucall $method --uri=localhost --port=6567 ...$params
			| complete
		if $call_result.exit_code != 0 {
			error make {
				label: {text: "rpc: ucall failed"}
				msg: $call_result.stderr
				help: ""
			}
		}
		let response = $call_result.stdout
			| from json
		if $response.error? != null {
			error make {
				label: {text: "rpc: ucall error"}
				msg: ($response.error | to json)
				help: ""
			}
		}
		$response
	}
}

# query searches for memories for the given query
export def query [--threshold: float]: string -> table<id: int score: float text: string> {
	let query = $in
	let threshold: float = $threshold | default 0.0

	let results = ucall rag_query $"query='($query)'"
		| get result
	$results.ids
		| enumerate
		| insert contents {|i| $results.contents | get $i.index}
		| insert scores {|i| $results.scores | get $i.index}
		| select item contents scores
		| rename id text score
		| where score >= $threshold
		| sort-by score -r
}

# add creates a new memory and returns its id
export def add []: string -> int {
	let memory: string = $in
	ucall rag_add "--positional" $memory
		| get result
		| get 0
}

# relate creates a relationship between two memories
export def relate [child: int, parent: int, type: string]: nothing -> nothing {
	ucall rag_relate $"child=($child)" $"parent=($parent)" $"type='($type)'"
	null
}

