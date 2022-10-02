extends Button


func _on_ButtonSave_pressed():
	var data = $"/root/Main/Task".surrender_data()
	var file = File.new()
	file.open("user://tree.tre", File.WRITE)
	file.store_string(data)
	file.close()
