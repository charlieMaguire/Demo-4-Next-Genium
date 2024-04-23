extends Node2D

@export var already_open_chance = 30
@export var always_closed_chance = 20
@export var interacting_message = ""
@export var scene_inside_name = ""
var is_door_open = false
var is_always_closed = false


func open_door():
	if not is_always_closed:
		is_door_open = true
		$AnimatedSprite2D.animation = "open"


func close_door():
	is_door_open = false
	$AnimatedSprite2D.animation = "closed"


func close_door_forever():
	is_door_open = false
	is_always_closed = true
	$AnimatedSprite2D.animation = "always_closed"
	$DoorBody.queue_free()
