source ai-env.nu

mkdir docs

def "read document" []: nothing -> record {
	{
		id: read_document
		definition: {
			schema: {
				name: read_document
				description: "Returns the contents of a document given its reference path."
				parameters: {
					type: object
					properties: {
						path: {
							type: string
							description: "The document path."
						}
					}
					required: [path]
				}
			}
			handler: {|x, ctx|
				open $x.path
			}
		}
	}
}

def "create document" [contents: string]: nothing -> record {
	{
		id: create_document
		definition: {
			schema: {
				name: create_document
				description: "Saves a document to storage, returns an ID string reference to the document object."
				parameters: {
					type: object
					properties: {
						title: {
							type: string
							description: "Document title."
						}
						summary: {
							type: string
							description: "A summary of the document contents, which are already provided via implicit context."
						}
					}
					required: [title summary]
				}
			}
			handler: {|x, ctx|
				let id = random uuid
				let frontmatter = $x | to yaml
				let path = $"./docs/($id).md"
				$"---\n($frontmatter)---\n($contents)" | save -f $path
				print -e $"Saved: ($path)"
				$path
			}
		}
	}
}

def "doc prompt" [task: record<title: string, description: string>, context: list<string>, results: string]: nothing -> string {
	$"Create a document using the 'create_document' tool with a summary of the following task and results.

Then, respond with the summary you generated and the reference IDs returned by the 'create_document' tool in your response.

So the flow is: 1) perform a tool call 2) in the response, state summary and reference ID.

<task>
- Context:
($context | str join "\n")
- Title: ($task.title)
- Description: ($task.description)
</task>

<results>
($results)
</results>"
}

def "task prompt" [title: string, desc: string, context: list<string>, --with-delegate]: nothing -> string {
	let suffix: string = if $with_delegate {
		"Break down the task into a list of subtasks to other agents with the 'delegate' tool.

When all delegated tasks have been completed, write out a detailed summary of what you have accomplished and your reasoning for it.

The delegated tasks will return reference IDs to a more detailed report containing their results, make sure you include those reference IDs in your summary."
	} else {
		"Complete the task and write out a detailed summary of what you have accomplished and your reasoning for it."
	}

	$"You have been given the following task:

- Context:
($context | str join "\n")
- Title: ($title)
- Description: ($desc)

($suffix)"
}

def "delegate tool" [context: list<string>, depth: int, max_depth: int]: nothing -> record<id: string, definition: record> {
	let id = $"delegate_($depth)"
	if $id in $env.AI_TOOLS {
		return ($env.AI_TOOLS | get $id)
	}

	let handler = if $depth < ($max_depth - 1) {
		{|x, ctx|
			let child_context = $context | append $x.title
			let del_tool = delegate tool $child_context ($depth + 1) $max_depth
			ai ai-config-env-tools $del_tool.id $del_tool.definition
			ai ai-config-alloc-tools $del_tool.id -t [$del_tool.id]

			let task_results = task prompt $x.title $x.description $child_context --with-delegate
				| ai ai-do general -f [$del_tool.id] --out
				| $in.content

			let create_tool = create document $task_results
			ai ai-config-env-tools $create_tool.id $create_tool.definition
			ai ai-config-alloc-tools $create_tool.id -t [$create_tool.id]

			doc prompt $x $child_context $task_results
				| ai ai-do general -f [$create_tool.id] --out
				| $in.content
		}
	} else {
		{|x, ctx|
			let child_context = $context | append $x.title
			let task_results = task prompt $x.title $x.description $child_context
				| ai ai-do general --out
				| $in.content

			let create_tool = create document $task_results
			ai ai-config-env-tools $create_tool.id $create_tool.definition
			ai ai-config-alloc-tools $create_tool.id -t [$create_tool.id]

			doc prompt $x $child_context $task_results
				| ai ai-do general -f [$create_tool.id] --out
				| $in.content
		}
	}

	{
		id: $id
		definition: {
			schema: {
				name: delegate
				description: "Delegate a task to a sub-agent."
				parameters: {
					type: object
					properties: {
						title: {
							type: string
							description: "A brief summary of the task."
						}
						description: {
							type: string
							description: "Details and requirements for task completion."
						}
					}
					required: [title description]
				}
			}
			handler: $handler
		}
	}
}
