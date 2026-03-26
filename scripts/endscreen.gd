extends CanvasLayer

@onready var color_rect = $ColorRect
@onready var label = $Label

var can_continue = false


func _ready():
	visible = false
	
	color_rect.modulate.a = 0.8
	label.modulate = Color(1, 1, 1, 1)


func show_end_screen():
	print("🟣 EndScreen wird angezeigt")
	visible = true
	
	can_continue = false
	await get_tree().create_timer(0.3).timeout
	can_continue = true


func _input(event):
	if visible and can_continue and event.is_pressed():
		load_next_level()


func load_next_level():
	print("➡️ Next Level wird geladen")

	var current_scene = get_tree().current_scene.scene_file_path
	print("AKTUELLES LEVEL:", current_scene)

	# 🔥 FALL 1: Direktes Level (level_1.tscn usw.)
	if current_scene.contains("level_"):
		var number = current_scene.get_file().replace("level_", "").replace(".tscn", "").to_int()
		var next_path = "res://scenes/level_" + str(number + 1) + ".tscn"

		print("Nächstes Level:", next_path)

		if ResourceLoader.exists(next_path):
			get_tree().change_scene_to_file(next_path)
		else:
			print("🎉 Spiel geschafft!")
	
	# 🔥 FALL 2: Du bist in main.tscn
	else:
		print("⚠️ Kein level_ erkannt → lade level_2")
		get_tree().change_scene_to_file("res://level_2.tscn")
