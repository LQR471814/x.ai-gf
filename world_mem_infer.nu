source ai_env.nu
source mem_tools.nu

const prompt = "<context>
- You can access long-term memory through the use of the 'mem_*' tools.
- You can list all your memories with the 'mem_all' tool.
</context>

<task>
1. Use 'mem_all' to list all the memories.
2. Infer new possible statements from the memories.
3. Use 'mem_add' and 'mem_relate' to add these new statements to long-term memory while relating it to existing memories.
</task>"

$prompt | ai ai-do general -f [...$MEMORY_TOOLS]
