extends Control

class_name WaveCounter

@export var wave_manager: WaveManager

@onready var wave_indicator: Label = $Label

var wave_num: int = 0


func _ready():
	if wave_manager:
		wave_manager.all_waves_started.connect(_on_all_waves_started)
		wave_manager.all_waves_completed.connect(_on_all_waves_completed)

func _on_all_waves_started(wave_index):
	wave_indicator.text = str(wave_index)
	
func _on_all_waves_completed():
	wave_indicator.text = str(0)
