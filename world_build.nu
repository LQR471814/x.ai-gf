source ai-env.nu
source world_tools.nu

let read_doc_tool = read document
# we will stop at a certain depth (let's say 3)
let context: list<string> = [
	"you are building out a world setting for an AI-powered romance simulator where claire is the 'girlfriend' so to speak"
]

let del_tool = delegate tool $context 0 2

ai ai-config-env-tools $read_doc_tool.id $read_doc_tool.definition
ai ai-config-alloc-tools $read_doc_tool.id -t [$read_doc_tool.id]
ai ai-config-env-tools $del_tool.id $del_tool.definition
ai ai-config-alloc-tools $del_tool.id -t [$del_tool.id]

let task_title = "build out the life of college student claire"
let task_desc = "make sure that all aspects of her day-in-a-life have been described"

task prompt $task_title $task_desc $context --with-delegate
	| ai ai-do general -f [$del_tool.id] --out

