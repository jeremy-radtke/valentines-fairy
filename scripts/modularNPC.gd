extends Area2D
# ModularNPC.gd - Configurable NPC with dialogue bubbles

# ============================================
# EXPORTED VARIABLES
# ============================================

@export_group("Identity")
@export var npc_name: String = "Messenger"
@export var npc_sprite: Texture2D
@export var sprite_scale: Vector2 = Vector2(2.0, 2.0)

@export_group("Dialogue")
@export_multiline var dialogue_text: String = "Hello, forest princess!"
@export var dialogue_duration: float = 3.0

@export_group("Detection")
@export var detection_radius: float = 100.0
@export var auto_show: bool = true

# ============================================
# INTERNAL STATE
# ============================================

var player_in_range: bool = false
var current_dialogue: Control = null

@onready var sprite: Sprite2D = $Sprite2D if has_node("Sprite2D") else null
@onready var collision: CollisionShape2D = $CollisionShape2D if has_node("CollisionShape2D") else null

# ============================================
# READY
# ============================================

func _ready():
	# Setup sprite
	if npc_sprite and sprite:
		sprite.texture = npc_sprite
		sprite.scale = sprite_scale
		sprite.centered = true
	
	# Setup detection area
	if collision:
		var circle = CircleShape2D.new()
		circle.radius = detection_radius
		collision.shape = circle
	
	# Connect signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	print("📍 NPC '%s' ready!" % npc_name)

# ============================================
# DETECTION
# ============================================

func _on_area_entered(area: Area2D) -> void:
	"""When player enters detection radius"""
	if area.is_in_group("player"):
		player_in_range = true
		print("👤 Player near '%s'" % npc_name)
		
		if auto_show:
			show_dialogue()

func _on_area_exited(area: Area2D) -> void:
	"""When player leaves detection radius"""
	if area.is_in_group("player"):
		player_in_range = false
		hide_dialogue()

# ============================================
# DIALOGUE SYSTEM
# ============================================

func show_dialogue() -> void:
	"""Display dialogue bubble"""
	if current_dialogue:
		return  # Already showing
	
	print("💬 %s says: %s" % [npc_name, dialogue_text])
	
	# Create dialogue label
	var label = Label.new()
	label.text = dialogue_text
	label.add_theme_font_size_override("font_size", 24)
	label.custom_minimum_size = Vector2(400, 100)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.modulate = Color.WHITE
	
	# Create panel background
	var panel = PanelContainer.new()
	panel.add_child(label)
	panel.global_position = global_position - Vector2(200, 120)
	
	add_child(panel)
	current_dialogue = panel
	
	# Auto-hide after duration
	await get_tree().create_timer(dialogue_duration).timeout
	hide_dialogue()

func hide_dialogue() -> void:
	"""Hide dialogue bubble"""
	if current_dialogue:
		current_dialogue.queue_free()
		current_dialogue = null

# ============================================
# DEBUG
# ============================================

func _draw() -> void:
	"""Draw detection radius in editor"""
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, detection_radius, Color(0, 1, 0, 0.2))
