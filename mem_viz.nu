let sqlite = open ./rag/rag-meta.db

# hard wraps text according to spaces, ensures each line is < width
def "hard wrap" [width: int]: string -> string {
	$in
		| split words
		| reduce -f [""] {|word, lines|
			let word_len = ($word | str length) + 1
			let last_line = $lines | last
			if ($width - ($last_line | str length)) >= $word_len {
				let last_idx = ($lines | length) - 1
				let new_lines = $lines
					| update $last_idx ($last_line + " " +  $word)
				return $new_lines
			}
			$lines | append $word
		}
		| str join "\\n"
}

let body = $sqlite
	| query db "select
	cm.id as child_id,
	cm.content as child_content,
	pm.id as parent_id,
	pm.content as parent_content,
	r.relationship_type
from relationship r
inner join memory cm
	on r.child_memory_id = cm.id
inner join memory pm
	on r.parent_memory_id = pm.id"
	| inspect
	| each {|row|
		let child_text = $row.child_content | hard wrap 32
		let parent_text = $row.parent_content | hard wrap 32
		$"\t\"($child_text) \(($row.child_id)\)\" -> \"($parent_text) \(($row.parent_id)\)\" [label=\"($row.relationship_type)\"];"
	}
	| str join "\n"


$"digraph Memory {
graph [rankdir=TB];
($body)
}" | dot -Tpng -o output.png

xdg-open output.png
