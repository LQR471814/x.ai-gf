source ai-env.nu

def "task prompt" [title: string, desc: string, context: list<string>, --with-delegate]: nothing -> string {
	let suffix: string = if $with_delegate {
		"Break down the task into a list of subtasks to other agents with the 'delegate' tool.

You have a long-term memory you can access through the 'mem_*' tools, use this to store all relevant information pertaining to this task.

When all delegated tasks have been completed, write out a brief summary of what you have accomplished."
	} else {
		"Complete the task and write out a detailed summary of what you have accomplished and your reasoning for it."
	}

	$"You have been given the following task:

You have a long-term memory you can access through the 'mem_*' tools, use this to store all relevant information pertaining to this task.

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

			task prompt $x.title $x.description $child_context --with-delegate
				| ai ai-do general -f [memory $del_tool.id] --out
				| $in.content
		}
	} else {
		{|x, ctx|
			let child_context = $context | append $x.title
			task prompt $x.title $x.description $child_context
				| ai ai-do general -f [memory] --out
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
