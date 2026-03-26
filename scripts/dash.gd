extends CharacterBody2D

# Bewegung
const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Dash
const DASH_SPEED = 420.0
const DASH_TIME = 0.18
const DASH_COOLDOWN = 0.35

var is_dashing = false
var dash_timer = 0.0
var dash_cooldown = 0.0

# Coyote Time
var coyote_time = 0.15
var coyote_timer = 0.0

# Jump Buffer
var jump_buffer_time = 0.15
var jump_buffer_timer = 0.0

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

# HP BAR (IM INSPECTOR SETZEN!)
@export var hp_bar: ProgressBar


func _ready():
	respawn_position = global_position
	add_to_group("player")

	if hp_bar:
		hp_bar.max_value = max_hp
		update_hp_bar()
	else:
		print("HP BAR NICHT ZUGEWIESEN")


func _physics_process(delta):
	if dead:
		return

	# Jump Buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# Dash Timer
	if is_dashing:
		dash_timer -= delta
		if dash_timer <= 0:
			is_dashing = false

	if dash_cooldown > 0:
		dash_cooldown -= delta

	# Gravity
	if not is_on_floor() and not is_dashing:
		velocity.y += gravity * delta

	# Coyote Time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Jump
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0

	# Bewegung
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

	# Dash
	if Input.is_action_just_pressed("dash") and dash_cooldown <= 0:
		is_dashing = true
		dash_timer = DASH_TIME
		dash_cooldown = DASH_COOLDOWN

	# Sprite drehen
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Animationen
	if is_dashing:
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


# HEAL
func heal(amount):
	if dead:
		return
	
	hp = min(hp + amount, max_hp)
	update_hp_bar()


# TOD
func die():
	if dead:
		return
	
	dead = true
	velocity = Vector2.ZERO

	animated_sprite.play("death")
	await animated_sprite.animation_finished

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


# CHECKPOINT
func activate_checkpoint(position: Vector2):
	respawn_position = position


# 🔥 HP BAR SYSTEM
func update_hp_bar():
	if hp_bar == null:
		return

	# Wert setzen
	hp_bar.value = hp

	# Prozent berechnen
	var percent = float(hp) / float(max_hp) * 100.0

	# Farbe wechseln
	if percent > 70:
		hp_bar.modulate = Color(0, 1, 0) # Grün
	elif percent > 30:
		hp_bar.modulate = Color(1, 1, 0) # Gelb
	else:
		hp_bar.modulate = Color(1, 0, 0) # Rot
