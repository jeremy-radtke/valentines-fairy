extends Camera2D
# CameraController.gd - Handles intro zoom and player following

# ============================================
# EXPORTED VARIABLES
# ============================================

@export var intro_start_zoom: float = 5.0    # How zoomed IN we start
@export var gameplay_zoom: float = 1.0       # Normal gameplay zoom
@export var follow_smoothing: bool = true
@export var follow_speed: float = 5.0

# ============================================
# INTERNAL VARIABLES
# ============================================

var is_intro_active: bool = true
var zoom_tween: Tween

# ============================================
# READY
# ============================================

func _ready():
	# Set initial zoom (very close)
	zoom = Vector2(intro_start_zoom, intro_start_zoom)
	
	# Enable camera
	enabled = true
	
	# Listen for game state changes
	GameManager.game_state_changed.connect(_on_game_state_changed)
	
	# Start the intro zoom after a short delay
	await get_tree().create_timer(0.5).timeout
	start_intro_zoom()

# ============================================
# INTRO ZOOM ANIMATION
# ============================================

func start_intro_zoom():
	# Create a tween (like Unity's DOTween)
	zoom_tween = create_tween()
	zoom_tween.set_trans(Tween.TRANS_QUAD)  # Smooth easing
	zoom_tween.set_ease(Tween.EASE_OUT)
	
	# Animate zoom from close to normal
	zoom_tween.tween_property(
		self,
		"zoom",
		Vector2(gameplay_zoom, gameplay_zoom),
		GameManager.intro_zoom_duration
	)
	
	# When zoom finishes, enable gameplay
	zoom_tween.finished.connect(_on_intro_zoom_finished)

func _on_intro_zoom_finished():
	is_intro_active = false
	GameManager.change_game_state("GAMEPLAY")
	print("Intro zoom finished - Gameplay active!")

# ============================================
# CAMERA FOLLOWING
# ============================================

func _process(delta):
	if follow_smoothing and not is_intro_active:
		# Smooth follow (optional)
		# Camera already follows player since it's a child node
		pass

# ============================================
# STATE MANAGEMENT
# ============================================

func _on_game_state_changed(new_state: String):
	match new_state:
		"ENDING":
			# Could do a special zoom animation for ending
			pass
