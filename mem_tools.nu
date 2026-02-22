use rag
source ai-env.nu

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
	handler: {|x|
		let id = $x.text | rag add
		{memory_id: $id}
	}
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
	handler: {|x|
		rag query --threshold 0
	}
}

ai ai-config-env-tools mem_relate {
	schema: {
		name: mem_relate
		description: "Creates a relationship from one memory to another."
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
	handler: {|x|
		rag relate $x.child_memory_id $x.parent_memory_id --type $x.relationship_type
	}
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
	handler: {|x|
		rag info $x.memory_id
	}
}

ai ai-config-alloc-tools memory -t [mem_query mem_add mem_info mem_relate]

const MEMORY_TOOLS: list<string> = [mem_add mem_query mem_relate mem_info]
