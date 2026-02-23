source ai_env.nu
source world_tools.nu

# we will stop at a certain depth (let's say 3)
let context: list<string> = [
	"you are building out a world setting for an AI-powered romance simulator where claire is the 'girlfriend' so to speak"
]

let del_tool = delegate tool $context 0 4

ai ai-config-env-tools $del_tool.id $del_tool.definition
ai ai-config-alloc-tools $del_tool.id -t [$del_tool.id]

let task_title = "Build out the life of college student Claire."
let task_desc = "Make sure that all aspects of her day-in-a-life have been described.
This is because to make her realistic, we will want to flesh out the logical constraints that she must abide by, then add style, not the other way around."

task prompt $task_title $task_desc $context --with-delegate
	| ai ai-do general -q -f [...$MEMORY_TOOLS $del_tool.id] --out

