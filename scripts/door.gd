extends Node2D

@export var move_distance: float = 16
@export var speed: float = 0.5

var open_position: Vector2
var closed_position: Vector2

var is_closed = false


func _ready():
	open_position = position
	closed_position = position + Vector2(0, move_distance)


func close():
	if is_closed:
		return
	
	is_closed = true
	
	var tween = create_tween()
	tween.tween_property(self, "position", closed_position, speed)


func open():
	if not is_closed:
		return
	
	is_closed = false
	
	var tween = create_tween()
	tween.tween_property(self, "position", open_position, speed)
