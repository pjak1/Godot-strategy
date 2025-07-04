extends Resource

class_name WaveSet

# === Exported Variables ===
@export var waves: Array[Wave] = []

# === Public Methods ===
func get_number_of_waves() -> int:
	return waves.size()
