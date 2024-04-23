extends Node2D

var player_pos_on_exiting
@onready var current_scene = $CurrentScene.get_children()[0]


func _ready():
	#remove temp data from previous session
	clear_temp()

	#set player starting position
	$Player.position = $CurrentScene/Village.find_child("PlayerDefaultPos").position

	#randomize doors statement in the village's houses
	var houses = get_tree().get_nodes_in_group("houses")
	for n in houses:
		if randf_range(0.0, 1.0) > 1.0 - n.always_closed_chance * 0.01:
			n.close_door_forever()
		else:
			if randf_range(0.0, 1.0) > 1.0 - n.already_open_chance * 0.01:
				n.open_door()
			else:
				n.close_door()


func clear_temp():
	#check if temp folder exists. if yes, delete all files inside. if not, create new one
	if DirAccess.dir_exists_absolute("user://temp"):
		var temp_files = DirAccess.get_files_at("user://temp")
		for n in temp_files:
			DirAccess.remove_absolute("user://temp/" + str(n))
	else:
		DirAccess.make_dir_absolute("user://temp")


func _on_player_colliding_door(body):
	#handling doors-keys mechanic
	#if going to exit building, no issue
	if current_scene.is_in_group("inside_building"):
		change_scene(body)
	#if going to enter building and door is open, no issue
	elif body.get_parent().is_door_open:
		change_scene(body)
	#if door is closed and player has keys, remove key and open the door
	elif $Player.keys > 0:
		$Player.update_keys(-1)
		body.get_parent().open_door()
		change_scene(body)


func change_scene(body):
	#saving scene statement
	var json = JSON.new()
	var path = "user://temp/" + str(current_scene.name) + ".json"
	var file = FileAccess.open(path, FileAccess.WRITE)
	var saving_data = {}
	#saving consumables statement
	saving_data["consumables"] = []
	var consumables = get_tree().get_nodes_in_group("consumables")
	for n in consumables:
		saving_data["consumables"].append(n.name)

	#saving interactables statement
	saving_data["interactables"] = {}
	var interactables = get_tree().get_nodes_in_group("interactable")
	for n in interactables:
		saving_data["interactables"][n.name] = n.is_light_on

	#saving houses statement if necessary
	if current_scene.is_in_group("zones"):
		var houses = get_tree().get_nodes_in_group("houses")
		saving_data["houses"] = {}
		for n in houses:
			saving_data["houses"][n.name] = {}
			saving_data["houses"][n.name]["always closed"] = n.is_always_closed
			saving_data["houses"][n.name]["open"] = n.is_door_open

	file.store_line(json.stringify(saving_data))
	file.close()

	#decide which scene must be loaded
	var loading_dir
	if current_scene.is_in_group("zones"):
		loading_dir = str("res://Scenes/" + body.get_parent().scene_inside_name)
		#remember player pos if entering building
		player_pos_on_exiting = body.get_parent().find_child("ExitPositionMarker").global_position
	elif current_scene.is_in_group("inside_building"):
		loading_dir = "res://Scenes/village.tscn"

	#delete current scene
	current_scene.free()

	#load new scene
	var new_scene = load(loading_dir).instantiate()

	#set player pos
	if new_scene.is_in_group("zones"):
		$Player.position = player_pos_on_exiting
	elif new_scene.is_in_group("inside_building"):
		$Player.position = new_scene.find_child("PositionOnEnteringMarker").global_position

	#show new scene
	$CurrentScene.add_child(new_scene)
	current_scene = $CurrentScene.get_children()[0]

	#recover consumables on level from loaded data
	path = "user://temp/" + str(current_scene.name) + ".json"
	if FileAccess.file_exists(path):
		file = FileAccess.open(path, FileAccess.READ)
		var loaded_data = json.parse_string(file.get_as_text())
		consumables = get_tree().get_nodes_in_group("consumables")
		for n in consumables:
			if not loaded_data["consumables"].has(n.name):
				n.queue_free()
		
		interactables = get_tree().get_nodes_in_group("interactable")
		for n in interactables:
			if loaded_data["interactables"][n.name] == true:
				n.turn_on()
	#recover interactables on level from loaded data
	
	#saving_data["interactables"] = {}
	#var interactables = get_tree().get_nodes_in_group("interactables")
	#for n in interactables:
		#saving_data["interactables"][n.name] = n.is_light_on

		#if entering village, recover doors statement from loaded data
		if current_scene.is_in_group("zones"):
			var houses = get_tree().get_nodes_in_group("houses")
			for n in houses:
				if loaded_data["houses"][n.name]["always closed"] == true:
					n.close_door_forever()
				else:
					if loaded_data["houses"][n.name]["open"] == true:
						n.open_door()
					else:
						n.close_door()
		file.close()


func _on_player_update_hud(function, data):
	if function == "update_hp":
		$HUD.update_hp(data[0], data[1])
	if function == "update_keys":
		$HUD.update_keys(data)
	if function == "update_message":
		$HUD.update_message(data)
