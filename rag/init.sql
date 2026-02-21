create table memory (
	id integer primary key autoincrement,
	content text not null
);

create table relationship (
	child_memory_id integer not null references memory(id)
		on update cascade
		on delete cascade,
	parent_memory_id integer not null references memory(id)
		on update cascade
		on delete cascade,
	relationship_type text not null,
	primary key (child_memory_id, parent_memory_id)
);

