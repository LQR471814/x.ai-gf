source ai_env.nu
source mem_tools.nu

let request = "Create a scene involving Claire."

let prompt = $"You are a writer who is tasked with generating the most likely new scene of the world.

The current datetime is: (date now | format date '%Y-%m-%d %H:%M')

The user's requirements are: '($request)'

You can access long-term memory containing information about the world with the 'mem_query' tool.

Respond with the new scene."

$prompt | ai ai-do general -f [...$MEMORY_TOOLS] --out

