extends Node
# GameManager.gd - Global Game State Manager (Singleton/Autoload)

# ============================================
# SIGNALS
# ============================================

signal game_state_changed(new_state: String)
signal fairy_collected(count: int)

# ============================================
# EXPORTED VARIABLES
# ============================================

@export var max_fairies: int = 5
@export var intro_zoom_duration: float = 3.0

# ============================================
# INTERNAL STATE
# ============================================

var fairies_collected: int = 0
var game_state: String = "INTRO"  # "INTRO", "GAMEPLAY", "ENDING"

# ============================================
# READY
# ============================================

func _ready():
	print("🎮 GameManager initialized! (Autoload Singleton)")
	change_game_state("INTRO")

# ============================================
# STATE MANAGEMENT
# ============================================

func change_game_state(new_state: String) -> void:
	"""Change game state and emit signal"""
	if game_state == new_state:
		return  # Don't change if already in this state
	
	game_state = new_state
	print("📍 Game State: ", game_state)
	game_state_changed.emit(game_state)
	
	match game_state:
		"INTRO":
			print("🎬 Starting intro sequence...")
		"GAMEPLAY":
			print("🎮 Gameplay started!")
		"ENDING":
			print("🎉 Game ending sequence started!")

# ============================================
# FAIRY COLLECTION
# ============================================

func collect_fairy() -> void:
	"""Called when player catches a fairy"""
	fairies_collected += 1
	print("✨ Fairy caught! Total: %d / %d" % [fairies_collected, max_fairies])
	fairy_collected.emit(fairies_collected)
	
	# Check if game is won
	if fairies_collected >= max_fairies:
		trigger_ending()

func trigger_ending() -> void:
	"""Trigger the game ending sequence"""
	if game_state == "ENDING":
		return  # Already ending
	
	change_game_state("ENDING")
	print("💕 ALL FAIRIES SAVED! Game Complete!")

# ============================================
# GETTERS
# ============================================

func get_fairy_count() -> int:
	return fairies_collected

func get_game_state() -> String:
	return game_state

func get_max_fairies() -> int:
	return max_fairies
