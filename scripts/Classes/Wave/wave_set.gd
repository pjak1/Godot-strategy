extends Resource

class_name WaveSet

@export var waves: Array[Wave] = []

func get_number_of_waves() -> int:
	return waves.size()
