extends Button


func _on_ButtonLoad_pressed():
	var file = File.new()
	if file.file_exists("user://tree.tre"):
		file.open("user://tree.tre", File.READ)
		var data = file.get_as_text()
		file.close()
		print(data)
		if data != null:
			$"/root/Main".load_tree(data)
	else:
		$"/root/Main".add_child($"/root/Main".TASK.instance())
