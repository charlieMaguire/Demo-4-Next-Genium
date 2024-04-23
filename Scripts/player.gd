extends CharacterBody2D

signal colliding_door
signal update_hud

@export var speed = 220

var keys = 0
var health = 0
var max_health = 10
var interacting = false
var interactable_object


func _input(_event):
	if Input.is_action_just_pressed("interact"):
		if interactable_object:
			interactable_object.switch()

	if Input.is_action_just_pressed("restart_game"):
		get_tree().reload_current_scene()


func _ready():
	#default animation
	$Sprite2D.animation = "walk_right"
	$Area2D/CollisionShape2D.position = $CollisionShape2D.position + Vector2(25, 0)

	health = max_health
	update_hud.emit("update_hp", [health, max_health])
	update_hud.emit("update_keys", keys)


func _process(delta):
	#movement
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	velocity = velocity.normalized()
	position += velocity * speed * delta

	#changing movement animations and rotating Area2D
	if velocity.x < 0:
		$Sprite2D.animation = "walk_left"
		$Area2D/CollisionShape2D.position = $CollisionShape2D.position + Vector2(-25, 0)
	if velocity.x > 0:
		$Sprite2D.animation = "walk_right"
		$Area2D/CollisionShape2D.position = $CollisionShape2D.position + Vector2(25, 0)
	if velocity.x == 0 and velocity.y != 0:
		if velocity.y > 0:
			$Sprite2D.animation = "walk_down"
			$Area2D/CollisionShape2D.position = $CollisionShape2D.position + Vector2(0, 25)
		else:
			$Sprite2D.animation = "walk_up"
			$Area2D/CollisionShape2D.position = $CollisionShape2D.position + Vector2(0, -25)

	move_and_slide()


func _on_area_2d_body_exited(body):
	if body.is_in_group("interactable"):
		update_hud.emit("update_message", "")
		interacting = false
		interactable_object = null


func _on_area_2d_body_entered(body):
	$Area2D.monitoring = false
	if body.is_in_group("player"):
		pass
	if body.is_in_group("interactable"):
		interacting = true
		interactable_object = body
		update_hud.emit("update_message", body.interacting_message)
	if body.is_in_group("doors"):
		colliding_door.emit(body)


func update_keys(qty):
	keys += qty
	update_hud.emit("update_keys", keys)


func update_hp(qty):
	if qty > 0 and health < max_health:
		health += qty
	elif qty < 0:
		health += qty
	update_hud.emit("update_hp", [health, max_health])

	if health <= 0:
		die()


func update_max_hp(qty):
	max_health += qty
	if qty < 0 and health > max_health:
		update_hp(max_health - health)
	update_hud.emit("update_hp", [health, max_health])


func die():
	get_tree().reload_current_scene()


func _on_timer_timeout():
	$Area2D.monitoring = true
