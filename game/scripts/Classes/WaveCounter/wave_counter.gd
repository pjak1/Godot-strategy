extends Node

class_name WaveCounter

# === Exported Variables ===
@export var wave_manager: WaveManager

# === Onready Variables ===
@onready var wave_indicator: Label = $HBoxContainer/Label

# === Runtime Variables ===
var wave_num: int = 0

# === Lifecycle ===
func _ready() -> void:
	if wave_manager:
		wave_manager.all_waves_started.connect(_on_all_waves_started)
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)

# === Signal Handlers ===
func _on_all_waves_started(wave_index: int) -> void:
	wave_indicator.text = str(wave_index)

func _on_all_waves_completed() -> void:
	wave_indicator.text = str(0)
