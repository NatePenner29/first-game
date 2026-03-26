extends Node


var score = 0

@onready var score_label: Label = $"Score Label"

func add_point():
	score +=1
	score_label.text = "You collected " + str(score) + " coins "


func _on_end_trigger_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
