extends Node2D

var level_done = false
var label = null


func _ready():
	# Label sicher holen (kein Crash mehr)
	label = get_node_or_null("EndScreen/Label")
	
	if label != null:
		label.visible = false
	else:
		print("❌ Label nicht gefunden! Prüfe den Pfad!")


func _on_exit_body_entered(body):
	if body.name == "Player" and !level_done:
		level_done = true
		show_level_complete()


func show_level_complete():
	if label != null:
		label.visible = true
	
	get_tree().paused = true


func _input(event):
	# "Press any button"
	if level_done and event.is_pressed():
		load_next_level()


func load_next_level():
	get_tree().paused = false
	
	var current_scene = get_tree().current_scene.scene_file_path
	var level_number = get_level_number(current_scene)
	
	var next_level = level_number + 1
	var next_path = "res://level_" + str(next_level) + ".tscn"
	
	if ResourceLoader.exists(next_path):
		get_tree().change_scene_to_file(next_path)
	else:
		print("🎉 Spiel geschafft!")
		# optional:
		# get_tree().change_scene_to_file("res://win_screen.tscn")


func get_level_number(path):
	var file = path.get_file()
	var number = file.replace("level_", "").replace(".tscn", "")
	return int(number)
