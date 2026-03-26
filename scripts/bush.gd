extends Node2D

@export var speed = 0.0
@export var texture_width = 512 # 👈 an dein Bild anpassen!

@onready var sprite1 = $Sprite1
@onready var sprite2 = $Sprite2

func _ready():
	# Startposition setzen (falls noch nicht gemacht)
	sprite1.position.x = 0
	sprite2.position.x = texture_width


func _process(delta):
	# Bewegung
	sprite1.position.x -= speed
	sprite2.position.x -= speed

	# Loop
	if sprite1.position.x <= -texture_width:
		sprite1.position.x = sprite2.position.x + texture_width

	if sprite2.position.x <= -texture_width:
		sprite2.position.x = sprite1.position.x + texture_width
