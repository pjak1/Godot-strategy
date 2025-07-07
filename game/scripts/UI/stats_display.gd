extends Node

class_name StatsDisplay

# === Exported Variables ===
@export var stat_name: String

# === Onready Variables ===
@onready var text: Label = $Text
@onready var value: Label = $Value

# === Lifecycle ===
func _ready() -> void:
	set_text(stat_name)
	set_value(0)

# === Public Methods ===
func set_value(new_value: int) -> void:
	value.text = str(new_value)

func set_text(new_text: String) -> void:
	text.text = new_text
