extends Area2D
# FairyFriend.gd - Floating fairy with catching and particle effects

# ============================================
# EXPORTED VARIABLES
# ============================================

@export_group("Movement")
@export var fly_speed: float = 50.0
@export var bob_height: float = 30.0
@export var bob_frequency: float = 2.0

@export_group("Visuals")
@export var fairy_sprite: Texture2D
@export var fairy_color: Color = Color.PINK
@export var sprite_scale: Vector2 = Vector2(2.0, 2.0)

@export_group("Catching")
@export var drop_chance: float = 1.0  # 0.0 to 1.0

# ============================================
# INTERNAL STATE
# ============================================

var time_elapsed: float = 0.0
var start_position: Vector2
var is_caught: bool = false

@onready var sprite: Sprite2D = $Sprite2D

# ============================================
# READY
# ============================================

func _ready():
	# Add to fairies group (for player detection)
	add_to_group("fairies")
	
	# Store starting position
	start_position = global_position
	
	# Setup sprite
	if fairy_sprite and sprite:
		sprite.texture = fairy_sprite
		sprite.scale = sprite_scale
		sprite.centered = true
		sprite.modulate = fairy_color
	
	# Randomize start time for variation
	time_elapsed = randf() * TAU

# ============================================
# FLOATING ANIMATION
# ============================================

func _process(delta):
	if is_caught:
		return
	
	time_elapsed += delta
	
	# Sine wave bobbing (up and down)
	var bob_offset = sin(time_elapsed * bob_frequency) * bob_height
	
	# Horizontal drifting (left and right)
	var drift = cos(time_elapsed * 0.5) * fly_speed * 0.5
	
	# Apply movement
	global_position.y = start_position.y + bob_offset
	global_position.x = start_position.x + drift

# ============================================
# CATCHING LOGIC
# ============================================

func get_caught() -> void:
	"""Called when player catches this fairy"""
	if is_caught:
		return
	
	is_caught = true
	print("✨ Fairy caught!")
	
	# Play catch effects
	play_catch_effect()
	
	# Drop collectible (maybe)
	if randf() <= drop_chance:
		spawn_jar_collectible()
	
	# Wait for effects to finish, then remove
	await get_tree().create_timer(0.5).timeout
	queue_free()

# ============================================
# VISUAL EFFECTS
# ============================================

func play_catch_effect() -> void:
	"""Play fade-out and scale animation"""
	if not sprite:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Fade out
	tween.tween_property(sprite, "modulate:a", 0.0, 0.5)
	
	# Scale up
	tween.tween_property(sprite, "scale", sprite_scale * 1.5, 0.5)

# ============================================
# COLLECTIBLES
# ============================================

func spawn_jar_collectible() -> void:
	"""Spawn a glass jar collectible at fairy position"""
	# This creates a simple visual jar (you can expand this later)
	var jar = Node2D.new()
	jar.global_position = global_position
	get_parent().add_child(jar)
	
	# Add a simple circle to represent the jar
	var circle = CircleShape2D.new()
	circle.radius = 8.0
	
	# TODO: Replace with actual jar sprite/scene
	print("💧 Glass jar dropped at position: ", global_position)
