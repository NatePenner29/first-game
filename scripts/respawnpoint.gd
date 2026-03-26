extends Area2D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.has_method("_on_respawn_point_body_entered"):
		body._on_respawn_point_body_entered(global_position)
