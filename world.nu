source ai_env.nu
source mem_tools.nu

export def "gen step" [] {
	let prompt = $"You are a writer who is tasked generating the currently occurring sequence of events that are happening to Claire.

The current datetime is: (date now | format date '%Y-%m-%d %H:%M %A')

You can access long-term memory containing information about the world with the 'mem_query' tool.

Long-term memory only contains generalities about the world so it doesn't contain current information about what Claire's currently doing or highly specific information like particular events.

You should make inferences for what could be happening and follow the information inside memory."

	$prompt | ai ai-do general -f [...$MEMORY_TOOLS] --out
}

export def "commit events" []: string -> nothing {
	let events = $in
	let prompt = $"Commit the following sequence events to memory using the 'mem_add' tool and relate it to existing memories (which you can find with 'mem_query') using the 'mem_relate' tool.

<events>
($events)
</events>"
	$prompt | ai ai-do general -f [...$MEMORY_TOOLS] --out
}

