extends Node2D

@export var link_length := 5.0         # Abstand zwischen den Gliedern
@export var swing_amplitude := 3.0     # maximale Pendelwinkel (Rad)
@export var swing_speed := 2.0          # Geschwindigkeit des Pendelns
@export var spike_rotation_speed := 5.0 # Rotation Spikeball

@onready var chain_links := [$ChainLink1, $ChainLink2, $ChainLink3, $ChainLink4, $ChainLink5]
@onready var spikeball := $Spikeball
@onready var root := $ChainRoot

var time_passed := 0.0

func _process(delta):
	time_passed += delta
	var angle := sin(time_passed * swing_speed) * swing_amplitude

	# Kettenglieder setzen
	var prev_pos : Vector2 = root.global_position
	for link in chain_links:
		link.global_position = prev_pos + Vector2(0, link_length).rotated(angle)
		link.rotation = angle
		prev_pos = link.global_position

	# Spikeball positionieren + rotieren
	spikeball.global_position = prev_pos + Vector2(24, link_length).rotated(angle)
	spikeball.rotation = angle
