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
	randomize()
	_reminder()


func _reminder():
	print(OS.get_name())
	if OS.get_name() == "X11":
		OS.execute("notify-send", [_get_leaf_text(), "-e"])
	$Ding.play()
	var timer = get_tree().create_timer(2 * 60)
	timer.connect("timeout", self, "_reminder")


func _get_leaf_text():
	var leaves = _get_leaves()
	return leaves[rand_range(0, leaves.size())].get_task_path()


func _get_leaves():
	var root = $"/root/Main/Task"
	var queue = [root]
	var visited = [root]
	var leaves = []
	var node
	while queue.size() > 0:
		node = queue.pop_front()
		var neighbors: Array = node.get_child_tasks()
		if neighbors.size() > 0:
			for neighbor in neighbors:
				if !visited.has(neighbor):
					queue.append(neighbor)
					visited.append(neighbor)
		else:
			leaves.append(node)
	return leaves
