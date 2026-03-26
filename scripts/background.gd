extends Node2D

@onready var cam = get_viewport().get_camera_2d()

@onready var sky = $Sky
@onready var layer_4 = $Layer4
@onready var layer_3 = $Layer3
@onready var layer_2 = $Layer2
@onready var layer_1 = $Layer1
@onready var bush = $Bush
@onready var vines = $Vines

# Startpositionen
var sky_start
var l4_start
var l3_start
var l2_start
var l1_start
var bush_start
var vines_start


func _ready():
	sky_start = sky.global_position
	l4_start = layer_4.global_position
	l3_start = layer_3.global_position
	l2_start = layer_2.global_position
	l1_start = layer_1.global_position
	bush_start = bush.global_position
	vines_start = vines.global_position


func _process(delta):
	if cam == null:
		return

	var cam_x = cam.global_position.x

	sky.global_position.x = sky_start.x + (cam_x * 0.1)
	layer_4.global_position.x = l4_start.x + (cam_x * 0.2)
	layer_3.global_position.x = l3_start.x + (cam_x * 0.4)
	layer_2.global_position.x = l2_start.x + (cam_x * 0.6)
	layer_1.global_position.x = l1_start.x + (cam_x * 0.8)
	bush.global_position.x = bush_start.x + (cam_x * 1.0)
	vines.global_position.x = vines_start.x + (cam_x * 1.2)
