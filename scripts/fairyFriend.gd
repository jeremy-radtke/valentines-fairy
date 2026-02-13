extends Area2D
# FairyFriend.gd - Floating fairy that can be caught

# ============================================
# EXPORTED VARIABLES
# ============================================

@export_group("Movement")
@export var fly_speed: float = 50.0          # Horizontal movement speed
@export var bob_height: float = 30.0         # How high/low it bobs
@export var bob_frequency: float = 2.0       # How fast it bobs

@export_group("Visuals")
@export var fairy_texture: Texture2D         # Drag sprite here
@export var fairy_color: Color = Color.PINK  # Tint color

@export_group("Drop System")
@export var jar_collectible_scene: PackedScene  # The "Glass Jar" prefab
@export var drop_chance: float = 1.0            # 0.0 to 1.0 (100% = always drop)

# ============================================
# INTERNAL VARIABLES
# ============================================

var time_elapsed: float = 0.0
var start_position: Vector2
var is_caught: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer if has_node("AnimationPlayer") else null

# ============================================
# READY
# ============================================

func _ready():
	# Add to fairies group (so player can find all fairies)
	add_to_group("fairies")
	
	# Store starting position
	start_position = global_position
	
	# Apply texture if set
	if fairy_texture and sprite:
		sprite.texture = fairy_texture
		sprite.modulate = fairy_color
	
	# Randomize starting time for variation
	time_elapsed = randf() * PI * 2

# ============================================
# PROCESS (Floating Animation)
# ============================================

func _process(delta):
	if is_caught:
		return  # Stop moving when caught
	
	time_elapsed += delta
	
	# Sine wave bobbing (up and down)
	var bob_offset = sin(time_elapsed * bob_frequency) * bob_height
	
	# Optional: Horizontal drift
	var drift_offset = cos(time_elapsed * 0.5) * fly_speed * delta
	
	# Apply movement
	global_position.y = start_position.y + bob_offset
	global_position.x += drift_offset

# ============================================
# CATCHING LOGIC
# ============================================

func get_caught():
	"""Called by PlayerController when player catches this fairy"""
	if is_caught:
		return  # Already caught
	
	is_caught = true
	
	print("Fairy caught!")
	
	# Play catch animation/effect
	play_catch_effect()
	
	# Drop collectible jar (if chance succeeds)
	if randf() <= drop_chance:
		spawn_jar_collectible()
	
	# Increment global fairy count
	GameManager.collect_fairy()
	
	# Remove this fairy from scene
	await get_tree().create_timer(0.5).timeout  # Wait for effect
	queue_free()  # Delete this node

func play_catch_effect():
	"""Visual/audio effect when caught"""
	# Create a tween for disappearing effect
	if sprite:
		var fade_tween = create_tween()
		fade_tween.tween_property(sprite, "modulate:a", 0.0, 0.5)  # Fade out
		fade_tween.parallel().tween_property(sprite, "scale", Vector2(2, 2), 0.5)  # Grow
	
	# TODO: Play sparkle particle effect
	# TODO: Play "catch" sound effect

func spawn_jar_collectible():
	"""Spawn the Glass Jar collectible"""
	if not jar_collectible_scene:
		print("Warning: No jar_collectible_scene assigned!")
		return
	
	var jar_instance = jar_collectible_scene.instantiate()
	get_parent().add_child(jar_instance)
	jar_instance.global_position = global_position

# ============================================
# VISUAL DEBUGGING
# ============================================

func _draw():
	if Engine.is_editor_hint():
		# Draw movement range
		draw_circle(Vector2.ZERO, bob_height, Color(0, 1, 1, 0.2))
