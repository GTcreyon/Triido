class_name Task
extends Panel
# Individual node in the tree, denoting a particular task or goal.
# Can be connected to sub-tasks and super-tasks.

var distance = 256
var branch_angle = 0
var true_scale = 1

onready var parent = get_parent()
onready var super_parent = get_parent().get_parent()
onready var connector = $Line2D
onready var anchor = $ChildAnchor
onready var title = $Title


func _ready():
	if parent.name != "ChildAnchor":
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


func _on_ButtonAdd_pressed():
	var inst = load("res://task.tscn").instance()
	anchor.add_child(inst)
	arrange_children()


func arrange_children():
	var ang_range
	var children = anchor.get_children()
	var num_of_children = children.size()
	for i in range(num_of_children):
		var angle
		if parent.name == "ChildAnchor":
			ang_range = PI / 2
			var middle: float = (num_of_children - 1.0) / 2.0
			var offset: float = (i - middle) * 2 / max(num_of_children - 1.0, 1)
			angle = branch_angle + (offset * ang_range / 2)
		else:
			angle = i * TAU / num_of_children
		children[i].rect_position = Vector2(cos(angle), sin(angle)) * (distance + num_of_children * 26)
		children[i].branch_angle = angle
		children[i].rect_scale = Vector2.ONE * 0.875
		children[i].true_scale = true_scale * 0.875
		children[i].arrange_children()


func hide_except(id):
	for child in anchor.get_children():
		if child != id:
			child.hide_except(null)
			child.modulate.a = 0.25


func show_branch_higher():
	modulate.a = 1
	if parent.name == "ChildAnchor":
		super_parent.show_branch_higher()


func hide_branch_higher():
	if parent.name == "ChildAnchor":
		super_parent.hide_except(self)
		super_parent.hide_branch_higher()


func show_branch_lower():
	for child in anchor.get_children():
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
		for child in anchor.get_children():
			output += child.surrender_data()
	return output + ";"


func set_title(text) -> void:
	title.text = text


func _on_ButtonArchive_pressed():
	queue_free()
	parent.remove_child(self)
	super_parent.arrange_children()


func _on_Task_gui_input(event):
	if event is InputEventMouseButton && modulate.a >= 1:
		$"/root/Main/Camera".slide_to(rect_global_position + (rect_size / 2) * true_scale, Vector2.ONE * true_scale)
		show_branch()
		hide_branch_higher()