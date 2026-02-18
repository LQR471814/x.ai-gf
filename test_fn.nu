source ./ai-env.nu

def add [a: float, b: float]: nothing -> float {
	$a + $b
}

ai ai-config-env-tools add {
	context: {}
	schema: {
		name: add
		description: "Add adds two floating-point numbers together."
		parameters: {
			type: object
			properties: {
				a: {type: number description: "The first number to add."}
				b: {type: number description: "The second number to add."}
			}
			required: [a b]
		}
	}
	handler: {|x, ctx|
		$x.a + $x.b
	}
}


ai ai-config-alloc-tools add -t [add]

print $env.AI_TOOLS

"calculate 300858 + 829333, do not calculate manually, use the 'add' tool" | ai ai-do general -f [add]
