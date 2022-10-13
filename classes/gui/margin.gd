extends Control

func _process(_delta):
	_update_safe_area()

func _update_safe_area():
	var safe_area: Rect2 = OS.get_window_safe_area()
	var full_area = OS.window_size
	margin_left = safe_area.position.x
	margin_top = safe_area.position.y
	margin_right = full_area.x - safe_area.size.x - safe_area.position.x
	margin_right = full_area.y - safe_area.size.y - safe_area.position.y
