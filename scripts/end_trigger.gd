extends Area2D

@onready var end_screen = get_node("../EndScreen")

func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if body.is_in_group("player"):
		print("🏆 Ende erreicht!")
		end_screen.show_end_screen()
