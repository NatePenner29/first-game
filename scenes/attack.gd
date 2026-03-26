extends CharacterBody2D

# Bewegung
const SPEED = 130.0
const JUMP_VELOCITY = -300.0
var jump_count = 0

# Dash
const DASH_SPEED = 420.0
const DASH_TIME = 0.18
const DASH_COOLDOWN = 0.35

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown = 0.0

# Attack 🔥
var is_attacking = false
var attack_cooldown = 0.3

# Physik
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Status
var dead = false

# HP
var max_hp = 100
var hp = 100
var invincible = false

# Respawn
var respawn_position: Vector2

# Nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var hp_bar = $HPBar/ProgressBar
@onready var attack_hitbox = $AttackHitbox


func _ready():
	respawn_position = global_position
	add_to_group("player")

	if hp_bar:
		hp_bar.max_value = max_hp
		update_hp_bar()

	if attack_hitbox:
		attack_hitbox.monitoring = false
		attack_hitbox.scale.x = 1


func _physics_process(delta):
	if dead:
		return

	# DASH
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	if dash_cooldown > 0:
		dash_cooldown -= delta

	# Gravity
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta
	else:
		jump_count = 0

	# Double Jump
	if Input.is_action_just_pressed("jump") and jump_count < 2:
		jump_count += 1
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction = Input.get_axis("move_left", "move_right")

	if is_dashing:
		if direction == 0:
			direction = -1 if animated_sprite.flip_h else 1
		velocity.x = direction * DASH_SPEED
		velocity.y = 0
	else:
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)

	# Dash starten
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0:
		is_dashing = true
		dash_timer = DASH_TIME
		dash_cooldown = DASH_COOLDOWN

	# Attack
	if Input.is_action_just_pressed("attack") and not is_attacking:
		start_attack()

	# Sprite drehen
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Animationen
	if is_attacking:
		pass
	elif is_dashing:
		animated_sprite.play("dash")
	else:
		if is_on_floor():
			if direction == 0:
				animated_sprite.play("idle")
			else:
				animated_sprite.play("walk")
		else:
			animated_sprite.play("jump")

	move_and_slide()


# 🥊 ATTACK SYSTEM
func start_attack():
	is_attacking = true

	var direction = -1 if animated_sprite.flip_h else 1
	attack_hitbox.scale.x = direction

	attack_hitbox.monitoring = true
	animated_sprite.play("attack")

	await get_tree().create_timer(0.1).timeout

	var bodies = attack_hitbox.get_overlapping_bodies()

	for body in bodies:
		if body.is_in_group("enemy"):
			if body.has_method("take_damage"):
				body.take_damage(20)

	attack_hitbox.monitoring = false

	await get_tree().create_timer(attack_cooldown).timeout
	is_attacking = false


# DAMAGE
func take_damage(amount):
	if dead or invincible:
		return
	
	invincible = true
	hp -= amount
	update_hp_bar()
	
	if hp <= 0:
		die()
	
	await get_tree().create_timer(1.0).timeout
	invincible = false


# 🍎 HEAL
func heal(amount):
	if dead:
		return
	
	hp = min(hp + amount, max_hp)
	update_hp_bar()


# 💀 TOD (FINAL FIX)
func die():
	if dead:
		return
	
	dead = true
	velocity = Vector2.ZERO

	print("💀 Spieler gestorben")

	animated_sprite.play("death")

	await animated_sprite.animation_finished

	# 🔥 ERST Arena resetten
	print("🔄 Arena wird resetet")
	get_tree().call_group("arena", "reset_arena")

	# 🔥 DANN respawn
	respawn()


# RESPAWN
func respawn():
	collision.disabled = true

	global_position = respawn_position + Vector2(0, -10)
	velocity = Vector2.ZERO
	hp = max_hp

	update_hp_bar()

	await get_tree().create_timer(0.2).timeout

	collision.disabled = false
	dead = false

	print("🟢 Spieler respawned")


# CHECKPOINT
func activate_checkpoint(position: Vector2):
	respawn_position = position


# HP BAR
func update_hp_bar():
	if hp_bar == null:
		return

	hp_bar.value = hp

	var percent = float(hp) / float(max_hp) * 100.0

	if percent > 70:
		hp_bar.modulate = Color(0, 1, 0)
	elif percent > 30:
		hp_bar.modulate = Color(1, 1, 0)
	else:
		hp_bar.modulate = Color(1, 0, 0)
