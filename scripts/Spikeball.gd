extends Area2D

@export var speed = 140  # Bewegungsgeschwindigkeit
@export var rotate_speed = 5  # Wie schnell sich der Spikeball dreht

@onready var point_a = $PointA
@onready var point_b = $PointB

var target
var going_to_b = true

func _ready():
	# Sorgt dafür, dass das Signal bei Spieler‑Berührung ausgelöst wird
	self.body_entered.connect(_on_body_entered)

	# Startposition
	global_position = point_a.global_position
	target = point_b.global_position

func _process(delta):
	# Rotation wie ein rollender Ball – nur zur Optik
	rotation += rotate_speed * delta

	# Beacon‑Style Rollbewegung
	var direction = (target - global_position).normalized()
	global_position += direction * speed * delta

	# Wenn nah am Ziel, direkt umkehren
	if global_position.distance_to(target) <= 1.0:
		if going_to_b:
			target = point_a.global_position
		else:
			target = point_b.global_position
		going_to_b = !going_to_b

func _on_body_entered(body):
	# Wenn der Spieler den Ball berührt, löscht ihn
	if body.name == "Player" or "Dash":
		body.queue_free()
