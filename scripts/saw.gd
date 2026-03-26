extends Area2D

@export var speed : float = 100.0
@export var rotation_speed : float = 5.0

@onready var point_a = get_parent().get_node("PointA")
@onready var point_b = get_parent().get_node("PointB")

var target : Vector2
var going_to_b : bool = true


func _ready():
	
	global_position = point_a.global_position
	target = point_b.global_position
	
	body_entered.connect(_on_body_entered)


func _physics_process(delta):
	# Rotation
	rotation += rotation_speed * delta

	# Bewegung
	global_position = global_position.move_toward(target, speed * delta)


	# Ziel wechseln
	if global_position.distance_to(target) < 1:
		going_to_b = !going_to_b
		target = point_b.global_position if going_to_b else point_a.global_position


func _on_body_entered(body):
	if not body.is_in_group("player"):
		return
	
	if body.dead:
		return
	
	print("🪚 Säge getroffen!")

	body.call_deferred("die")
