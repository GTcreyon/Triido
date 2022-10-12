extends Control

const TASK = preload("res://classes/task/task.tscn")


func load_tree(data: String):
	var i = 0
	var title = ""
	var stack = [$"/root/Main/"]
	while i < data.length():
		var chr = data[i]
		if chr == ":" or chr == ";":
			if title != "":
				var new_task = TASK.instance()
				new_task.set_title(title)
				title = ""
				if stack[0].name == "Main":
					stack[0].add_child(new_task)
				else:
					stack[0].get_node("ChildAnchor").add_child(new_task)
				stack.push_front(new_task)
			if chr == ";":
				stack.pop_front()
		else:
			title += chr
		i += 1
	$"/root/Main/Task".arrange_children()
