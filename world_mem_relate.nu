source ai_env.nu
source mem_tools.nu

const prompt = "<context>
- You can access long-term memory through the use of the 'mem_*' tools.
- You can list all your memories with the 'mem_all' tool.
</context>

<task>
- First use 'mem_all' to list all the memories.
- Use the 'mem_relate' tool to draw relationships between memories.
- If you need to examine the relationships for a given memory, you can use 'mem_info'.
</task>

<success_conditions>
- All possible relationships between memories have been established.
- Memory relationships are clear and sensible.
</success_conditions>"

$prompt | ai ai-do general -f [...$MEMORY_TOOLS]
