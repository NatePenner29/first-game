extends Node2D

@onready var trigger = $Trigger
@onready var door_top = get_node_or_null("DoorTop")
@onready var door_bottom = get_node_or_null("DoorBottom")
@onready var spawn_points_node = get_node_or_null("SpawnPoints")

@export var enemy_scene: PackedScene
@export var move_distance: float = 16
@export var waves: Array[int] = [3, 5, 7]
@export var spawn_spread: float = 20

var spawn_points: Array = []

var fight_started = false
var enemies_alive = 0
var current_wave = 0

# 🚪 Positionen
var door_top_open_pos
var door_top_closed_pos
var door_bottom_open_pos
var door_bottom_closed_pos


func _ready():
	add_to_group("arena") # 🔥 wichtig für reset

	if door_top == null or door_bottom == null:
		print("❌ Door fehlt!")
		return

	if spawn_points_node == null:
		print("❌ SpawnPoints fehlt!")
		return

	spawn_points = spawn_points_node.get_children()

	trigger.body_entered.connect(_on_player_entered)

	door_top_open_pos = door_top.position
	door_bottom_open_pos = door_bottom.position

	door_top_closed_pos = door_top.position + Vector2(0, move_distance)
	door_bottom_closed_pos = door_bottom.position + Vector2(0, -move_distance)

	set_doors_collision(false)


func _on_player_entered(body):
	if body.is_in_group("player") and not fight_started:
		start_fight()


func start_fight():
	fight_started = true
	close_doors()
	start_wave()


# 🚪 Türen schließen
func close_doors():
	var tween = create_tween()

	tween.tween_property(door_top, "position", door_top_closed_pos, 0.5)
	tween.parallel().tween_property(door_bottom, "position", door_bottom_closed_pos, 0.5)

	await tween.finished
	set_doors_collision(true)


# 🚪 Türen öffnen
func open_doors():
	set_doors_collision(false)

	var tween = create_tween()

	tween.tween_property(door_top, "position", door_top_open_pos, 0.5)
	tween.parallel().tween_property(door_bottom, "position", door_bottom_open_pos, 0.5)


# 🔥 WAVES
func start_wave():
	if current_wave >= waves.size():
		print("✅ Alle Waves geschafft!")
		open_doors()
		return

	print("🔥 Wave:", current_wave + 1)

	var amount = waves[current_wave]
	spawn_enemies(amount)


# 👾 SPAWNEN (FIXED)
func spawn_enemies(amount):
	if enemy_scene == null:
		print("❌ enemy_scene nicht gesetzt!")
		return

	if spawn_points.is_empty():
		print("❌ Keine SpawnPoints!")
		return

	for i in range(amount):
		var point = spawn_points.pick_random()

		var offset = Vector2(
			randf_range(-spawn_spread, spawn_spread),
			randf_range(-spawn_spread * 0.5, spawn_spread * 0.5)
		)

		var enemy = enemy_scene.instantiate()
		enemy.global_position = point.global_position + offset

		enemy.add_to_group("arena_enemy")

		get_parent().add_child(enemy)

		enemies_alive += 1

		# 🔥 FIX: echtes death signal
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)


# 💀 WAVE LOGIK (STABIL)
func _on_enemy_died():
	if not fight_started:
		return

	enemies_alive -= 1

	print("💀 Gegner down:", enemies_alive)

	if enemies_alive <= 0:
		current_wave += 1
		await get_tree().create_timer(1.5).timeout
		start_wave()


# 🧱 Collision
func set_doors_collision(state: bool):
	for block in door_top.get_children():
		if block is StaticBody2D:
			block.set_collision_layer_value(1, state)

	for block in door_bottom.get_children():
		if block is StaticBody2D:
			block.set_collision_layer_value(1, state)


# 🔄 RESET (JETZT STABIL)
func reset_arena():
	print("🔄 GLOBAL RESET START")

	fight_started = false
	current_wave = 0
	enemies_alive = 0

	open_doors()

	# 👾 Nur Arena Gegner löschen
	for enemy in get_tree().get_nodes_in_group("arena_enemy"):
		if enemy.is_inside_tree():
			enemy.queue_free()

	# 💀 Normale Skelette resetten
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.has_method("reset_enemy"):
			enemy.reset_enemy()

	# 🍎 Äpfel resetten
	for apple in get_tree().get_nodes_in_group("apple"):
		if apple.has_method("reset_apple"):
			apple.reset_apple()

	print("✅ GLOBAL RESET FERTIG")
