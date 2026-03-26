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
	
	print("🪦 Spike getroffen!")

	# 👇 Spieler stirbt (Animation + Respawn)
	body.die()

	# kleine Pause gegen mehrfaches Auslösen
	await get_tree().create_timer(0.5).timeout
	triggered = false
