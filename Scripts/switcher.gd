extends StaticBody2D

signal update_hud
@export var interacting_message = ""
var is_light_on = false


func _on_area_entered(area):
	if area.get_parent().is_in_group("player"):
		update_hud.emit(interacting_message)


func switch():
	if is_light_on:
		turn_off()
	else:
		turn_on()


func turn_on():
	if $DirectionalLight2D.enabled == false:
		$DirectionalLight2D.enabled = true
		$AnimatedSprite2D.animation = "on"
		is_light_on = true


func turn_off():
	if $DirectionalLight2D.enabled == true:
		$DirectionalLight2D.enabled = false
		$AnimatedSprite2D.animation = "off"
		is_light_on = false

