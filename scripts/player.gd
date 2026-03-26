extends CharacterBody2D

# Bewegung
const SPEED = 130.0
const JUMP_VELOCITY = -300.0

# Coyote Time
var coyote_time := 0.15
var coyote_timer := 0.0

# Jump Buffer
var jump_buffer_time := 0.15
var jump_buffer_timer := 0.0

# Fallgrenze
@export var death_y := 800

# ❤️ HP (DEIN SYSTEM)
var max_hp = 100
var hp = 100
var invincible = false

# Physik
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

# Status
var dead = false

# Startposition
var start_position: Vector2

# Nodes
@onready var animated_sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D


func _ready():
	start_position = global_position
	add_to_group("player")


func _physics_process(delta):
	if dead:
		return

	# Jump Buffer
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer -= delta

	# Gravity
	if not is_on_floor():
		velocity.y += gravity * delta

	# Coyote Time
	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer -= delta

	# Springen
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = JUMP_VELOCITY
		jump_buffer_timer = 0
		coyote_timer = 0

	# Bewegung
	var direction = Input.get_axis("move_left", "move_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Sprite drehen
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	# Animationen
	if is_on_floor():
		if direction == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("walk")
	else:
		animated_sprite.play("jump")

	move_and_slide()

	# 💀 Falltod (nutzt dein Damage-System)
	if global_position.y > death_y:
		take_damage(999)


# ❤️ DAMAGE (DEIN ORIGINAL)
func take_damage(amount):
	if dead or invincible:
		return
	
	invincible = true
	hp -= amount
	
	print("HP:", hp)
	
	if hp <= 0:
		die()
	
	await get_tree().create_timer(1.0).timeout
	invincible = false


# 💚 HEAL (wie vorher)
func heal(amount):
	if dead:
		return
	
	hp = min(hp + amount, max_hp)


# 💀 TOD
func die():
	if dead:
		return
	
	dead = true
	velocity = Vector2.ZERO

	animated_sprite.play("death")
	await animated_sprite.animation_finished

	respawn()


# 🔄 RESPAWN
func respawn():
	collision.disabled = true

	global_position = start_position + Vector2(0, -10)

	velocity = Vector2.ZERO
	hp = max_hp

	await get_tree().create_timer(0.2).timeout

	collision.disabled = false
	dead = false
	
func activate_checkpoint(position: Vector2):
	start_position = position
	print("Checkpoint gesetzt:", start_position)
