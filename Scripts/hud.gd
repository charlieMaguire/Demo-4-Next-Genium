extends CanvasLayer


func update_keys(keys):
	$Keys.text = "Keys: %s" % keys


func update_hp(health, max_health):
	$HP.text = "HP: %s/%s" % [health, max_health]


func update_message(message):
	$MessageTImer.start()
	$Message.text = message


func _on_message_timer_timeout():
	$Message.text = ""
