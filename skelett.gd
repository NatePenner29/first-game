extends CharacterBody2D

signal died # 🔥 NEU (WICHTIG!)

@export var speed = 80
@export var damage = 10
@export var attack_range = 30
@export var lose_range = 200

# 🔥 HP SYSTEM
@export var max_hp = 50
var hp = 50
var dead = false

# 🔥 Startposition
var start_position: Vector2

# HIT TIMING
@export var hit_delay = 0.4
@export var hit_duration = 0.7

var player = null
var is_attacking = false
var has_hit = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@onready var sprite = $AnimatedSprite2D
@onready var attack_area = $AttackArea
@onready var hp_bar = $HPBar/ProgressBar

var attack_offset


func _ready():
	start_position = global_position

	attack_area.monitoring = false
	attack_offset = attack_area.position
	hp = max_hp

	add_to_group("enemy")

	hp_bar.max_value = max_hp
	update_hp_bar()
	hp_bar.visible = false


func _physics_process(delta):

	if dead:
		return

	if not is_on_floor():
		velocity.y += gravity * delta

	if player != null and not is_instance_valid(player):
		player = null

	if player != null and global_position.distance_to(player.global_position) > lose_range:
		player = null

	# 🔥 HIT CHECK
	if is_attacking and attack_area.monitoring and not has_hit:
		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				has_hit = true
				body.take_damage(damage)

	if player == null:
		velocity.x = 0
		if not is_attacking:
			sprite.play("idle")
	else:
		var distance = player.global_position.x - global_position.x
		var direction = sign(distance)

		sprite.flip_h = direction < 0

		if direction > 0:
			attack_area.position.x = abs(attack_offset.x)
		else:
			attack_area.position.x = -abs(attack_offset.x)

		if not is_attacking and abs(distance) < attack_range:
			if abs(player.global_position.y - global_position.y) < 60:
				attack()

		if not is_attacking:
			if abs(distance) > 20:
				velocity.x = direction * speed
				sprite.play("walk")
			else:
				velocity.x = 0
				sprite.play("idle")

	move_and_slide()


# 🥊 ATTACK
func attack():
	is_attacking = true
	has_hit = false
	velocity.x = 0
	
	sprite.play("attack")

	await get_tree().create_timer(hit_delay).timeout
	enable_hitbox()

	await get_tree().create_timer(hit_duration).timeout
	disable_hitbox()

	is_attacking = false


func enable_hitbox():
	attack_area.monitoring = true


func disable_hitbox():
	attack_area.monitoring = false


# 💥 DAMAGE
func take_damage(amount):
	if dead:
		return
	
	hp -= amount

	hp_bar.visible = true
	update_hp_bar()

	if hp <= 0:
		die()


# 💀 DEATH (FINAL FIX)
func die():
	if dead:
		return
	
	dead = true
	velocity = Vector2.ZERO
	attack_area.monitoring = false

	sprite.play("death")

	await sprite.animation_finished

	emit_signal("died") # 🔥 EXTREM WICHTIG für Waves

	# 👇 Unterschied zwischen Arena & normalen Gegnern
	if is_in_group("arena_enemy"):
		queue_free() # 👾 Arena Gegner werden gelöscht
	else:
		hide() # 💀 Normale bleiben
		set_physics_process(false)


# 🔄 RESET (nur für normale Skelette)
func reset_enemy():
	if is_in_group("arena_enemy"):
		return # ❗ Arena Gegner ignorieren

	print("💀 Skeleton reset")

	dead = false
	hp = max_hp
	global_position = start_position
	velocity = Vector2.ZERO

	show()
	set_physics_process(true)

	attack_area.monitoring = false
	is_attacking = false
	has_hit = false

	hp_bar.visible = false
	update_hp_bar()

	player = null


# 👀 VISION
func _on_vision_area_body_entered(body):
	if body.is_in_group("player"):
		player = body

func _on_vision_area_body_exited(body):
	if body == player:
		player = null


# ❤️ HP BAR
func update_hp_bar():
	if hp_bar == null:
		return
	
	hp_bar.value = hp
