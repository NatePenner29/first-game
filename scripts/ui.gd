extends CanvasLayer

@onready var hp_bar = $HPBar
var player = null

func _ready():
	await get_tree().process_frame  # 🔥 WICHTIG (wartet bis Player existiert)

	player = get_tree().get_first_node_in_group("player")

	if player == null:
		print("❌ PLAYER NICHT GEFUNDEN")
	else:
		print("✅ PLAYER GEFUNDEN")

	if player:
		hp_bar.max_value = player.max_hp


func _process(_delta):
	if player == null:
		return

	# ✅ VALUE UPDATEN
	hp_bar.value = player.hp

	# ✅ DEBUG (SEHR WICHTIG)
	print("HP:", player.hp)

	# ✅ FARBE
	var percent = float(player.hp) / float(player.max_hp) * 100.0

	if percent > 70:
		hp_bar.modulate = Color(0, 1, 0)
	elif percent > 30:
		hp_bar.modulate = Color(1, 1, 0)
	else:
		hp_bar.modulate = Color(1, 0, 0)
