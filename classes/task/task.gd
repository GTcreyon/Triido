class_name Task
extends Panel
# Individual node in the tree, denoting a particular task or goal.
# Can be connected to sub-tasks and super-tasks.

var distance = 256
var branch_angle = 0
var true_scale = 1

onready var anchor_parent = get_parent()
onready var super_parent = get_parent().get_parent()
onready var connector = $Line2D
onready var anchor = $ChildAnchor
onready var title = $Title


func _ready():
	if is_root():
		connector.queue_free()
		connector = null
	for child in get_children():
		if child.name.begins_with("Task"):
			print(child.name)
			remove_child(child)
			anchor.add_child(child)


func _process(_delta):
	if connector != null:
		connector.points[0] = rect_size / 2
		connector.points[1] = -rect_position / rect_scale.x + super_parent.rect_size / 2
	_update_mouse_filter()


func is_root() -> bool:
	return anchor_parent.name != "ChildAnchor"


func get_text() -> String:
	return title.text


func get_task_path() -> String:
	if is_root():
		return get_text()
	else:
		return super_parent.get_task_path() + "/" + get_text()


func get_child_tasks() -> Array:
	return anchor.get_children()


func arrange_children():
	var ang_range
	var children = get_child_tasks()
	var num_of_children = children.size()
	for i in range(num_of_children):
		var angle
		var branch_distance
		if anchor_parent.name == "ChildAnchor":
			ang_range = PI / 2
			var middle: float = (num_of_children - 1.0) / 2.0
			var offset: float = (i - middle) * 2 / max(num_of_children - 1.0, 1)
			angle = branch_angle + (offset * ang_range / 2)
			branch_distance = distance
		else:
			angle = i * TAU / num_of_children
			branch_distance = distance * 3 / 4
		children[i].rect_position = Vector2(cos(angle), sin(angle)) * (branch_distance + num_of_children * 26)
		children[i].branch_angle = angle
		children[i].rect_scale = Vector2.ONE * 0.875
		children[i].true_scale = true_scale * 0.875
		children[i].arrange_children()


func hide_except(id):
	for child in get_child_tasks():
		if child != id:
			child.hide_except(null)
			child.modulate.a = 0.25


func show_branch_higher():
	modulate.a = 1
	if anchor_parent.name == "ChildAnchor":
		super_parent.show_branch_higher()


func hide_branch_higher():
	if anchor_parent.name == "ChildAnchor":
		super_parent.hide_except(self)
		super_parent.hide_branch_higher()


func show_branch_lower():
	for child in get_child_tasks():
		child.modulate.a = 1
		child.show_branch_lower()


func show_branch():
	show_branch_lower()
	show_branch_higher()


func surrender_data() -> String:
	var text = title.text
	var output = text if text != "" else "NULL"
	if anchor.get_child_count() > 0:
		output += ":"
		for child in get_child_tasks():
			output += child.surrender_data()
	return output + ";"


func set_title(text) -> void:
	if !is_inside_tree():
		yield(self, "ready")
	title.text = text


func _on_ButtonArchive_pressed():
	queue_free()
	anchor_parent.remove_child(self)
	if anchor_parent.name == "ChildAnchor":
		super_parent.arrange_children()


func _on_Task_gui_input(event):
	if event is InputEventMouseButton:
		$"/root/Main/Camera".slide_to(rect_global_position + (rect_size / 2) * true_scale, Vector2.ONE * true_scale)
		show_branch()
		hide_branch_higher()


func _update_mouse_filter():
	if modulate.a < 1:
		mouse_filter = MOUSE_FILTER_IGNORE
	else:
		mouse_filter = MOUSE_FILTER_STOP
	for child in get_children():
		if child.is_class("Control"):
			child.mouse_filter = mouse_filter


func _on_ButtonAdd_pressed():
	var inst = load("res://classes/task/task.tscn").instance()
	anchor.add_child(inst)
	arrange_children()
