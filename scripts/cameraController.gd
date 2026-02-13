extends Camera2D
# CameraController.gd - Cinematic intro zoom and player following

# ============================================
# EXPORTED VARIABLES
# ============================================

@export_group("Intro")
@export var intro_start_zoom: float = 5.0    # Start zoomed IN
@export var intro_end_zoom: float = 1.0      # End at normal zoom
@export var intro_duration: float = 3.0      # Duration in seconds

@export_group("Following")
@export var follow_enabled: bool = true
@export var follow_offset: Vector2 = Vector2.ZERO

# ============================================
# INTERNAL STATE
# ============================================

var is_intro_active: bool = true
var zoom_tween: Tween
var player: Node2D

# ============================================
# READY
# ============================================

func _ready():
	# Store reference to player
	player = get_tree().root.find_child("Player", true, false)
	if not player:
		print("⚠️  Player not found in scene!")
		return
	
	# Make camera follow player
	set_physics_process(true)
	
	# Start with close zoom
	zoom = Vector2(intro_start_zoom, intro_start_zoom)
	global_position = player.global_position
	
	# Wait a frame for scene to settle, then start intro
	await get_tree().process_frame
	start_intro_zoom()

# ============================================
# INTRO ZOOM ANIMATION
# ============================================

func start_intro_zoom() -> void:
	"""Play the cinematic zoom out animation"""
	print("🎬 Intro zoom starting...")
	
	# Kill any existing tween
	if zoom_tween:
		zoom_tween.kill()
	
	# Create new tween
	zoom_tween = create_tween()
	zoom_tween.set_trans(Tween.TRANS_QUAD)
	zoom_tween.set_ease(Tween.EASE_OUT)
	zoom_tween.set_parallel(true)  # Run multiple tweens together
	
	# Zoom out smoothly
	zoom_tween.tween_property(
		self,
		"zoom",
		Vector2(intro_end_zoom, intro_end_zoom),
		intro_duration
	)
	
	# When done, start gameplay
	await zoom_tween.finished
	on_intro_finished()

func on_intro_finished() -> void:
	"""Called when intro zoom completes"""
	is_intro_active = false
	print("✅ Intro complete! Gameplay starting...")
	
	# Signal GameManager
	GameManager.change_game_state("GAMEPLAY")
	
	# Enable player movement
	player.enable_movement()

# ============================================
# CAMERA FOLLOWING
# ============================================

func _physics_process(_delta):
	"""Follow player during gameplay"""
	if follow_enabled and player and not is_intro_active:
		global_position = player.global_position + follow_offset

# ============================================
# STATE LISTENERS
# ============================================

func _on_game_state_changed(new_state: String) -> void:
	"""Listen for game state changes"""
	match new_state:
		"ENDING":
			# Could add special camera effect for ending
			disable_following()

func disable_following() -> void:
	"""Stop camera from following player"""
	follow_enabled = false
