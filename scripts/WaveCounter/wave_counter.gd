extends Control

class_name WaveCounter

@export var wave_manager: WaveManager

@onready var wave_indicator: Label = $Label

var wave_num: int = 0


func _ready():
	if wave_manager:
		wave_manager.connect("all_waves_started", _on_all_waves_started)
		
	wave_indicator.text = str(wave_num)

func _on_all_waves_started(wave_index):
	wave_indicator.text = str(wave_index)
