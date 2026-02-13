extends CharacterBody2D

# Inspector exports - drag & drop to configure!
@export var move_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0
@export var sprite_texture: Texture2D
@export var catch_cooldown: float = 0.5  # Delay between catching fairies

# Internal state
var can_move: bool = false  # Disabled during intro
var last_catch_time: float = 0.0
var gravity: float = 800.0  # For platformer physics

func _ready():
	# Setup sprite
	if sprite_texture:
		$Sprite2D.texture = sprite_texture
	
	# Initial state - can't move during intro
	can_move = false

func _physics_process(delta):
	# Apply gravity (simple platformer)
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0
	
	# Handle movement input (only when not in intro)
	if can_move:
		handle_movement(delta)
		handle_catch_input()
	
	# Apply velocity
	move_and_slide()

func handle_movement(delta):
	var input_dir = Input.get_axis("ui_left", "ui_right")
	
	if input_dir != 0:
		# Accelerate in input direction
		velocity.x = move_toward(velocity.x, input_dir * move_speed, acceleration * delta)
		
		# Flip sprite based on direction
		if input_dir > 0:
			$Sprite2D.flip_h = false
		else:
			$Sprite2D.flip_h = true
	else:
		# Apply friction when no input
		velocity.x = move_toward(velocity.x, 0, friction * delta)

func handle_catch_input():
	if Input.is_action_just_pressed("ui_accept"):  # "E" key
		# Check cooldown to prevent spam
		if Time.get_ticks_msec() - last_catch_time > catch_cooldown * 1000:
			try_catch_fairy()
			last_catch_time = Time.get_ticks_msec()

func try_catch_fairy():
	# This will be called by overlapping fairy detection
	print("Trying to catch a fairy!")
	GameManager.collect_fairy()

# Called by CameraController when intro is done
func enable_movement():
	can_move = true
	print("Player movement enabled!")
