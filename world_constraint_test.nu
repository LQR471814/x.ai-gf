source ./ai-env.nu

const username = "John"
const partner = "Claire"

def elaborate [constraints: list<string>] {
	if ($constraints | length) >= 20 {
		return {
			constraint: ($constraints | last)
			children: []
		}
	}
	let additional = $constraints | each {|it| $"- ($it)"} | str join "\n"

	$"I am designing a world with the following constraints:

	- modern day university setting
	- a person exists named ($partner)
	($additional)

	Brainstorm potential new constraints I can add that do not contradict the existing.

	Output a string[] in JSON."
		| ai ai-do short-thinking -o
		| get content
		| from json
		| each {|line|
			let new_constraints = $constraints | append $line
			elaborate $new_constraints
		}
		| {
			constraint: ($constraints | last)
			children: $in
		}
}

elaborate [
	"modern day university setting"
	$"a person exists named ($partner)"
]
	| to yaml

# the problem currently is that the AI is potentially wasting a lot of compute
# considering low-level constraints without fully working out the high-level
# constraints.

# the other more pertinent issue though, is eventually we will hit a wall where
# the context balloons out of proportion or creates way too much stuff for the
# AI to consider, or simply creates *noise* that reduces AI performance

# the golden rule of context-engineering is to keep only the information the AI
# absolutely needs to consider in the context, the rest is just noise that
# reduces AI performance.

# how to fix this? we will want to

# instead of going with a bottom-up approach where the AI is left free to roam
# through constraints, we want to make it so that the AI is guided in solving
# the problem top-down

