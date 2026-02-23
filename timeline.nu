source ai_env.nu
source mem_tools.nu
source world_tools.nu

let start: datetime = "7:00" | date from-human
let end: datetime = "22:00" | date from-human
let chunks: int = ($end - $start) / 30min | math floor

let context: list<string> = [
	"You can access long-term memory containing information about the world with the 'mem_query' tool, use it to gain insight into Claire's activities, obligations, social circle, etc..."
	$"The current day is: (date now | format date '%Y-%m-%d %A')"
	"You are to generate the events that will happen to Claire today using the information about the world stored in long-term memory."
]

let del_tool = delegate tool $context 0 1
ai ai-config-env-tools $del_tool.id $del_tool.definition
ai ai-config-alloc-tools $del_tool.id -t [$del_tool.id]

let template = 0..<$chunks
	| each {|i|
		let starting_time = $start + 30min * $i
		$"- ($starting_time | format date '%H:%M')-($starting_time + 30min | format date '%H:%M'): <events>"
	}
	| str join "\n"

$"# Task

($context | str join "\n")

# Execution

1. Begin by considering the high-level categories of things happening in different parts of the day \(morning, afternoon, evening, night\)
2. Delegate the brainstorming of the individual minutia to sub-agents with the 'delegate' tool.
3. Output the full schedule for today."
	| ai ai-do general -f [...$MEMORY_TOOLS $del_tool.id]
