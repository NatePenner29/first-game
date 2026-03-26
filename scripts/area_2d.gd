extends Area2D

var activated = false
@onready var end_screen = $"../EndScreen"


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):
	if activated:
		return
	
	if body.is_in_group("player"):
		activated = true
		print("🏆 ENDE ERREICHT")

		# Spieler stoppen
		if "velocity" in body:
			body.velocity = Vector2.ZERO
		
		body.set_physics_process(false)
		body.set_process(false)

		# EndScreen anzeigen
		if end_screen:
			end_screen.show_end_screen()
