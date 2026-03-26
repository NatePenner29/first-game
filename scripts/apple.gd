extends Area2D

@export var heal_amount = 5
var start_position: Vector2

func _ready():
	start_position = global_position
	add_to_group("apple") # 🔥 WICHTIG

func _on_body_entered(body):
	if body.is_in_group("player"):
		body.heal(heal_amount)
		hide()

func reset_apple():
	print("🍎 Apple reset")
	global_position = start_position
	show()
