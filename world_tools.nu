source ai_env.nu
source mem_tools.nu

def "task prompt" [title: string, desc: string, context: list<string>, --with-delegate]: nothing -> string {
	let execution: string = if $with_delegate {
		"1. Check your long-term memory to find relevant information pertaining to this task with `mem_query`.
2. Complete this task, break down details into relevant subtasks to delegate to other agents by generating multiple calls to the `delegate` tool.
3. Store completed task results into long-term memory and relate it to existing memories using the `mem_add` and `mem_relate` tools.
4. Respond with a brief summary of what you have accomplished."
	} else {
		"1. Check your long-term memory to find relevant information pertaining to this task with 'mem_query'.
2. Complete the task.
3. Store completed task results into long-term memory and relate it to existing memories using the `mem_add` and `mem_relate` tools.
4. Respond with a brief summary of what you have accomplished."
	}

	$"# Task

You have been given the following task.

- Title: ($title)
- Description: ($desc)
- Parent tasks:
($context | each {|it| '  - ' + $it} | str join "\n")

# Execution

($execution)"
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
				| ai ai-do general -q -f [...$MEMORY_TOOLS $del_tool.id] --out
				| $in.content
		}
	} else {
		{|x, ctx|
			let child_context = $context | append $x.title
			task prompt $x.title $x.description $child_context
				| ai ai-do general -q -f [...$MEMORY_TOOLS] --out
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
