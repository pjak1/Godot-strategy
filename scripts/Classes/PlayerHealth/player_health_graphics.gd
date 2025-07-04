extends Node

class_name PlayerHealthGraphics

# === Onready Variables ===
@onready var player_health_logic: PlayerHealthLogic = owner
@onready var label: Label = $Label

# === Runtime Variables ===
var current_lives: int = 0

# === Lifecycle ===

func _ready() -> void:
	player_health_logic.lives_changed.connect(_on_lives_changed)

# === Public Methods ===

func update_lives(new_value: int) -> void:
	label.text = str(new_value)

# === Signal Handlers ===

func _on_lives_changed(current: int, max: int) -> void:
	current_lives = current
	update_lives(current)
