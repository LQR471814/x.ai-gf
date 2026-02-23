use rag
source ai_env.nu

def "tool handler" []: closure -> closure {
	let fn = $in
	{|...params|
		let input = $in
		try {
			$input | do $fn ...$params
		} catch {|err|
			print -e $err
			error make $err
		}
	}
}

ai ai-config-env-tools mem_all {
	schema: {
		name: mem_all
		description: "List all memories."
		parameters: {
			type: object
			properties: {}
			required: []
		}
	}
	handler: ({|x|
		"" | rag query --threshold -inf
	} | tool handler)
}

ai ai-config-env-tools mem_add {
	schema: {
		name: mem_add
		description: "Add an atomic memory to long-term storage for later querying."
		parameters: {
			type: object
			properties: {
				text: {
					type: string
					description: "The atomic memory, should be 1 sentence."
				}
			}
			required: [text]
		}
	}
	handler: ({|x|
		let id = $x.text | rag add
		{memory_id: $id}
	} | tool handler)
}

ai ai-config-env-tools mem_query {
	schema: {
		name: mem_query
		description: "Find relevant information in your memory for this query, understands natural language."
		parameters: {
			type: object
			properties: {
				query: {
					type: string
					description: "The natural language query to use."
				}
			}
			required: [query]
		}
	}
	handler: ({|x|
		$x.query | rag query --threshold 0
	} | tool handler)
}

ai ai-config-env-tools mem_relate {
	schema: {
		name: mem_relate
		description: "Creates a relationship from one memory to another, it will return null on success."
		parameters: {
			type: object
			properties: {
				child_memory_id: {
					type: number
					description: "The child's memory ID."
				}
				parent_memory_id: {
					type: number
					description: "The parent's memory ID."
				}
				relationship_type: {
					type: string
					description: "The relationship type, must be one of:
- `extends`: indicates the child memory adds information to the parent memory
- `updates`: indicates that the child memory replaces the parent memory"
				}
			}
			required: [child_memory_id parent_memory_id relationship_type]
		}
	}
	handler: ({|x|
		rag relate $x.child_memory_id $x.parent_memory_id --type $x.relationship_type
	} | tool handler)
}

ai ai-config-env-tools mem_info {
	schema: {
		name: mem_info
		description: "Queries relationships for a given memory."
		parameters: {
			type: object
			properties: {
				memory_id: {
					type: number
					description: "The ID of the memory to query."
				}
			}
			required: [memory_id]
		}
	}
	handler: ({|x|
		rag info $x.memory_id
	} | tool handler)
}

ai ai-config-alloc-tools memory -t [mem_query mem_add mem_info mem_relate mem_all]

const MEMORY_TOOLS: list<string> = [mem_add mem_query mem_relate mem_info mem_all]
