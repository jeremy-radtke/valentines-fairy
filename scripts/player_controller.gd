extends CharacterBody2D
# PlayerController.gd - Princess movement and fairy catching

# ============================================
# EXPORTED VARIABLES
# ============================================

@export_group("Movement")
@export var move_speed: float = 200.0
@export var acceleration: float = 800.0
@export var friction: float = 600.0
@export var gravity: float = 800.0

@export_group("Sprites")
@export var sprite_texture: Texture2D
@export var sprite_scale: Vector2 = Vector2(2.0, 2.0)

@export_group("Catching")
@export var catch_radius: float = 80.0
@export var catch_cooldown: float = 0.5

# ============================================
# INTERNAL STATE
# ============================================

var can_move: bool = false
var last_catch_time: float = 0.0

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

# ============================================
# READY
# ============================================

func _ready():
	# Add to player group for detection
	add_to_group("player")
	
	# Setup sprite
	if sprite_texture and sprite:
		sprite.texture = sprite_texture
		sprite.scale = sprite_scale
		sprite.centered = true
	
	# Setup collision
	if collision:
		collision.position = Vector2.ZERO
	
	# Start frozen during intro
	can_move = false
	print("🎀 Princess ready! (Waiting for intro to finish)")

# ============================================
# PHYSICS PROCESS
# ============================================

func _physics_process(delta):
	# Apply gravity
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0  # Reset gravity when on ground
	
	# Handle input only during gameplay
	if can_move:
		handle_movement(delta)
		handle_catch_input()
	
	# Apply velocity to move the character
	move_and_slide()

# ============================================
# MOVEMENT LOGIC
# ============================================

func handle_movement(delta):
	"""Handle left/right movement with acceleration and friction"""
	var input_dir = Input.get_axis("ui_left", "ui_right")
	
	if input_dir != 0:
		# Accelerate toward target speed
		velocity.x = move_toward(velocity.x, input_dir * move_speed, acceleration * delta)
		
		# Flip sprite based on direction
		sprite.flip_h = (input_dir < 0)
	else:
		# Apply friction to slow down
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

# ============================================
# FAIRY CATCHING
# ============================================

func handle_catch_input():
	"""Handle player pressing E to catch nearby fairy"""
	if Input.is_action_just_pressed("ui_catch"):
		try_catch_fairy()

func try_catch_fairy() -> void:
	"""Check for nearby fairies and catch one"""
	# Cooldown check
	var current_time = Time.get_ticks_msec() / 1000.0
	if current_time - last_catch_time < catch_cooldown:
		return
	
	last_catch_time = current_time
	
	# Get all fairies in the scene
	var fairies = get_tree().get_nodes_in_group("fairies")
	
	# Find closest fairy within catch radius
	var closest_fairy = null
	var closest_distance = catch_radius
	
	for fairy in fairies:
		var distance = global_position.distance_to(fairy.global_position)
		if distance < closest_distance:
			closest_fairy = fairy
			closest_distance = distance
	
	# If we found a fairy, catch it!
	if closest_fairy:
		print("🎀 Caught a fairy!")
		closest_fairy.get_caught()

# ============================================
# STATE CHANGES
# ============================================

func enable_movement() -> void:
	"""Called by Camera when intro ends"""
	can_move = true
	print("🎀 Princess can move now!")

func disable_movement() -> void:
	"""Freeze player movement"""
	can_move = false
	velocity = Vector2.ZERO
