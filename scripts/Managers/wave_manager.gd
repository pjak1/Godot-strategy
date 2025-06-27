extends Node
class_name WaveManager

@export var spawners: Array[NodePath]
@export var wave_sets: Array[WaveSet]

var current_wave_index := 0
var running := false

func start_next_wave():
	if running:
		return
		
	running = true
	
	if spawners.size() != wave_sets.size():
		push_error("Spawner count must match WaveSet count!")
		return

	for i in range(spawners.size()):
		var spawner: Node = get_node(spawners[i])
		var wave_set: WaveSet = wave_sets[i]

		if current_wave_index < wave_set.waves.size():
			var wave: Wave = wave_set.waves[current_wave_index]
			spawner.start_wave(wave)

	current_wave_index += 1

func on_wave_finished():
	running = false
