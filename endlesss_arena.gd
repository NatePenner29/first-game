extends Node2D

@onready var trigger = $Trigger
@onready var spawn_points_node = $SpawnPoints

var wave_ui = null

@export var enemy_scene: PackedScene
@export var spawn_spread: float = 20

var spawn_points: Array = []

var fight_started = false
var enemies_alive = 0
var current_wave = 1


func _ready():
	add_to_group("arena")

	if trigger == null:
		print("❌ Trigger fehlt!")
		return

	if spawn_points_node == null:
		print("❌ SpawnPoints fehlt!")
		return

	spawn_points = spawn_points_node.get_children()

	trigger.body_entered.connect(_on_player_entered)

	# 🔥 WICHTIG: UI erst später holen
	await get_tree().process_frame

	wave_ui = get_tree().get_first_node_in_group("wave_ui")

	if wave_ui == null:
		print("❌ Wave UI NICHT gefunden!")
	else:
		print("✅ Wave UI verbunden!")


# 🎯 Spieler betritt Arena
func _on_player_entered(body):
	if body.is_in_group("player") and not fight_started:
		print("🔥 Endless Arena gestartet")
		start_fight()


func start_fight():
	fight_started = true
	start_wave()


# 🔥 WAVES
func start_wave():
	print("🔥 Wave:", current_wave)

	if wave_ui and wave_ui.has_method("show_wave"):
		wave_ui.show_wave(current_wave)
	else:
		print("❌ show_wave nicht gefunden!")

	spawn_enemies(current_wave)


# 👾 SPAWN
func spawn_enemies(amount):
	if enemy_scene == null:
		print("❌ enemy_scene fehlt!")
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

		get_parent().add_child(enemy)

		enemies_alive += 1

		# 🔥 WICHTIG: Signal verbinden
		if enemy.has_signal("died"):
			enemy.died.connect(_on_enemy_died)
		else:
			print("❌ Enemy hat kein 'died' Signal!")


# 💀 Gegner stirbt
func _on_enemy_died():
	enemies_alive -= 1
	print("💀 Gegner übrig:", enemies_alive)

	if enemies_alive <= 0:
		current_wave += 1

		await get_tree().create_timer(1.5).timeout
		start_wave()


# 🔄 RESET (bei Tod)
func reset_arena():
	print("🔄 Endless Arena Reset")

	fight_started = false
	current_wave = 1
	enemies_alive = 0

	# 👾 Gegner löschen
	for enemy in get_tree().get_nodes_in_group("enemy"):
		if enemy.is_inside_tree():
			enemy.queue_free()

	await get_tree().create_timer(0.2).timeout

	# 🔥 Spieler im Trigger → neu starten
	for body in trigger.get_overlapping_bodies():
		if body.is_in_group("player"):
			print("🔥 Restart direkt")
			start_fight()
			return

	print("⏳ Warte auf Spieler")
