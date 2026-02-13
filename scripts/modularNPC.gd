extends Area2D
# ModularNPC.gd - Modular messenger with inspector-configurable dialogue

# ============================================
# EXPORTED VARIABLES
# ============================================

@export_group("NPC Identity")
@export var npc_name: String = "Messenger"
@export var npc_sprite: Texture2D

@export_group("Dialogue")
@export_multiline var dialogue_text: String = "Hello, forest princess!"
@export var auto_show_dialogue: bool = true  # Show when player enters

@export_group("Detection")
@export var detection_radius: float = 100.0

# ============================================
# INTERNAL REFERENCES
# ============================================

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var dialogue_bubble: Control = $DialogueBubble if has_node("DialogueBubble") else null
@onready var dialogue_label: Label = $DialogueBubble/Panel/Label if has_node("DialogueBubble/Panel/Label") else null
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# ============================================
# READY
# ============================================

func _ready():
	# Apply sprite
	if npc_sprite and sprite:
		sprite.texture = npc_sprite
	
	# Set up detection area
	if collision_shape:
		var circle_shape = CircleShape2D.new()
		circle_shape.radius = detection_radius
		collision_shape.shape = circle_shape
	
	# Connect area signals
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Hide dialogue initially
	if dialogue_bubble:
		dialogue_bubble.visible = false

# ============================================
# INTERACTION
# ============================================

func _on_body_entered(body):
	"""When player enters detection radius"""
	if body.is_in_group("player"):
		if auto_show_dialogue:
			show_dialogue()

func _on_body_exited(body):
	"""When player leaves detection radius"""
	if body.is_in_group("player"):
		hide_dialogue()

func show_dialogue():
	"""Display the dialogue bubble"""
	if dialogue_bubble and dialogue_label:
		dialogue_label.text = dialogue_text
		dialogue_bubble.visible = true
		print(npc_name, " says: ", dialogue_text)

func hide_dialogue():
	"""Hide the dialogue bubble"""
	if dialogue_bubble:
		dialogue_bubble.visible = false

# ============================================
# VISUAL DEBUGGING
# ============================================

func _draw():
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, detection_radius, Color(0, 1, 0, 0.2))
