def recurse [] {
	let row = $in
	if (($row | describe) | str starts-with "list") {
		return {
			constraint: ($row | last)
			children: []
		}
	}
	return {
		constraint: $row.constraint
		children: ($row.children | each {|child|
			$child | recurse
		})
	}
}

open output.yml
	| recurse
	| to yaml

