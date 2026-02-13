extends Node

# Singleton pattern - this script runs once for the entire game
var fairies_collected: int = 0
var game_state: String = "intro"  # "intro", "gameplay", "ending"
var max_fairies: int = 5  # How many fairies to catch before ending

func _ready():
	# Make this node persist across scene changes
	set_name("GameManager")
	if not is_node_unique():
		queue_free()
		return
	
	print("GameManager initialized!")

# Called when player catches a fairy
func collect_fairy():
	fairies_collected += 1
	print("Fairies collected: %d / %d" % [fairies_collected, max_fairies])
	
	# Check if game is won
	if fairies_collected >= max_fairies:
		trigger_ending()

# Called when the intro camera zoom completes
func start_gameplay():
	game_state = "gameplay"
	print("Gameplay started!")

# Trigger the final message and ending
func trigger_ending():
	game_state = "ending"
	print("🎉 Game Complete! Show final message to player!")

# Get fairy collected count for UI
func get_fairy_count() -> int:
	return fairies_collected

func get_game_state() -> String:
	return game_state

func trigger_ending():
	game_state = "ending"
	print("🎉 You've saved all the fairies! 💕")
	
	# Show final message
	var final_message = Label.new()
	final_message.text = "Thank you for being my fairy guardian... Happy Valentine's Day! 💕"
	final_message.add_theme_font_size_override("font_size", 36)
	get_tree().root.get_node("Main/UI").add_child(final_message)
	final_message.global_position = Vector2(640, 360)
	
	# Pause game
	get_tree().paused = true
