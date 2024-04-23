extends Area2D


func _on_body_entered(body):
	if body.is_in_group("player"):
		var doors = get_tree().get_nodes_in_group("houses")
		if doors.size() > 0:
			for n in doors:
				if n.is_door_open == true:
					n.close_door()
		else:
			var json = JSON.new()
			var path = "user://temp/Village.json"
			var file = FileAccess.open(path, FileAccess.READ)
			var data = json.parse_string(file.get_as_text())
			file.close()

			for n in data["houses"]:
				data["houses"][n]["open"] = false
			file = FileAccess.open(path, FileAccess.WRITE)
			file.store_line(json.stringify(data))
			file.close()
		queue_free()
