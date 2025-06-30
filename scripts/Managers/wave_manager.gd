extends Node

class_name WaveManager

@export var spawners: Array[NodePath]

var current_wave_index: int = 0
var active_spawners: Array[Spawner] = []
var finished_spawners: int = 0
var all_waves_finished: bool = false

signal all_waves_started(wave_index: int)
signal all_waves_completed

func _ready():
	initialize_spawners()
	start_next_wave()

func initialize_spawners():
	active_spawners.clear()
	for path in spawners:
		var spawner: Spawner = get_node(path)
		
		if spawner:
			active_spawners.append(spawner)
			spawner.connect("wave_finished", _on_spawner_wave_finished)

func start_next_wave():
	if all_waves_finished:
		return
	
	finished_spawners = 0
	
	for spawner in active_spawners:
		spawner.start_wave()
	
	notify_all_waves_started()
	current_wave_index += 1

func _on_spawner_wave_finished():
	finished_spawners += 1

	if finished_spawners == active_spawners.size():
		if is_last_wave():
			all_waves_finished = true
			notify_all_waves_completed()
		else:
			start_next_wave()

func is_last_wave() -> bool:
	for spawner in active_spawners:
		if spawner.wave_index < spawner.wave_set.waves.size():
			return false
	return true

func notify_all_waves_completed():
	emit_signal("all_waves_completed")
	
func notify_all_waves_started():
	emit_signal("all_waves_started", current_wave_index)
