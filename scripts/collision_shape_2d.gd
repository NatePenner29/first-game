extends Node2D

# Schwung-Parameter
@export var amplitude_degrees = 60.0
@export var speed = 2.0

var time = 0.0
var amplitude_rad = 0.0

# Pfad zur Area2D
@onready var hit_area = $Area2D  # <<< Area2D wird hier referenziert

func _ready():
	# Umrechnung Grad → Radian (für Node2D.rotation)
	amplitude_rad = deg2rad(amplitude_degrees)
	
	# Signal body_entered vom Child Area2D verbinden
	hit_area.body_entered.connect(_on_body_entered)

func _physics_process(delta):
	time += delta * speed
	rotation = amplitude_rad * sin(time)  # Node2D rotiert → Sprite + Area folgen

# Spieler berührt Area2D
func _on_body_entered(body):
	if body.has_method("take_damage"):
		body.take_damage()  # Player stirbt sofort
