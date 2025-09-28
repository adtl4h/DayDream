extends CharacterBody2D

const SPEED = 120.0
const JUMP_VELOCITY = -400.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var blood_bar: ProgressBar = $BloodBar

var blood: float = 100.0  # percentage (0–100)

func _ready() -> void:
	blood_bar.min_value = 0
	blood_bar.max_value = 100
	blood_bar.step = 0.1
	blood_bar.value = blood

func _physics_process(delta: float) -> void:
	# Gravity
	if not is_on_floor():
		velocity.y += ProjectSettings.get_setting("physics/2d/default_gravity") * delta

	# Jump
	if Input.is_action_just_pressed("up") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Horizontal movement
	var direction := Input.get_axis("left", "right")
	if direction != 0:
		velocity.x = direction * SPEED
		animated_sprite.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# Animations
	if not is_on_floor():
		if velocity.y < 0:
			animated_sprite.play("jump")
		else:
			animated_sprite.play("fall")
	elif direction != 0:
		animated_sprite.play("run")
	else:
		animated_sprite.play("idle")

	# Move the character
	move_and_slide(velocity, Vector2.UP)

	# Attack input
	if Input.is_action_just_pressed("attack"):
		attack()

func attack() -> void:
	if blood > 0:
		blood -= 5.0
		blood = clamp(blood, 0, 100)
		blood_bar.value = blood
		animated_sprite.play("attack")
