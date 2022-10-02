extends Camera2D
# Main camera script.
# Controls movement around the tree, as well as zoom level.

const SLIDE_TIME: float = 60.0

var prev_drag_pos
var sliding: bool = false
var slide_progress: float = 0.0
var slide_position_start
var slide_position_end
var slide_zoom_start
var slide_zoom_end


func _process(_delta):
	var mouse_pos = get_local_mouse_position()
	if Input.is_action_pressed("cam_move"):
		position += prev_drag_pos - mouse_pos
	prev_drag_pos = mouse_pos
	if sliding:
		slide_progress += 1
		position = slide_position_start + (slide_position_end - slide_position_start) * ease_out(slide_progress / SLIDE_TIME)
		zoom = slide_zoom_start + (slide_zoom_end - slide_zoom_start) * ease_out(slide_progress / SLIDE_TIME)
		if slide_progress >= SLIDE_TIME:
			sliding = false
			position = slide_position_end


func slide_to(destination: Vector2, target_zoom: Vector2) -> void:
	sliding = true
	slide_progress = 0
	slide_position_start = position
	slide_position_end = destination
	slide_zoom_start = zoom
	slide_zoom_end = target_zoom


func ease_out(n: float) -> float:
	return sin((n * PI) / 2)


# Move the camera when the screen is dragged
func _input(event):
	if event is InputEventScreenDrag:
		position -= event.relative
