extends Node2D

@onready var area = $Area2D

var activated := false


func _on_area_2d_body_entered(body):
	if activated:
		return
	
func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		activated = true
		body.activate_checkpoint($RespawnPoint.global_position)
		print("Checkpoint gesetzt!")
