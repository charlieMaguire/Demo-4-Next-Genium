extends Area2D


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.update_hp(-1)
		queue_free()
