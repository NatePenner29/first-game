extends Area2D

var triggered = false

func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	
	if body.dead:
		return
	
	if triggered:
		return
	
	triggered = true
	

	body.die()

	# kleine Pause damit es nicht mehrfach triggert
	await get_tree().create_timer(0.5).timeout
	triggered = false
