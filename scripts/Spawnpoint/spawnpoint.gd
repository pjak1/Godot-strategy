extends Node2D

class_name Spawner

@export var enemy_logic_scene: PackedScene
@export var wave_set: WaveSet

var spawn_interval: float = 5.0
var spawn_timer := 0.0
var wave_enemies_remaining = -1
var wave_index = 0
var number_of_waves = 0
var enemy_data: EnemyData = null
var wave_already_finished := false

signal enemy_spawned
signal wave_started
signal wave_finished

func _ready():
	number_of_waves = wave_set.waves.size()

func _process(delta):
	update_spawn_timer(delta)
	handle_spawning()
	
	if wave_enemies_remaining == 0 and not wave_already_finished:
		wave_already_finished = true
		notify_wave_finished()

func update_spawn_timer(delta: float) -> void:
	spawn_timer += delta

func handle_spawning() -> void:
	var can_spawn := wave_index - 1 < number_of_waves \
		and spawn_timer >= spawn_interval \
		and wave_enemies_remaining > 0

	if can_spawn:
		spawn_timer = 0.0
		spawn_enemy()

func spawn_enemy() -> void:
	if not enemy_logic_scene:
		push_error("Enemy logic scene not set!")
		return

	var enemy = create_enemy()
	
	prepare_enemy(enemy)
	deploy_enemy(enemy)
	notify_enemy_spawned(enemy)

func create_enemy() -> EnemyLogic:
	var enemy: EnemyLogic = enemy_logic_scene.instantiate()
	
	enemy.initialize(enemy_data)
	enemy.global_position = global_position
	enemy.connect("died", _on_enemy_died)
	return enemy

func prepare_enemy(enemy: EnemyLogic) -> void:
	var path_points = find_closest_path_points(enemy.global_position)

	if path_points.is_empty():
		push_warning("Enemy %s does not have assigned path!" % enemy.name)
	else:
		enemy.set_path_points(path_points)
		enemy.enable_movement = true

func deploy_enemy(enemy: EnemyLogic) -> void:
	get_parent().add_child(enemy)
	enemy.add_to_group("Enemy")

func notify_enemy_spawned(enemy: EnemyLogic) -> void:
	emit_signal("enemy_spawned", enemy)

func find_closest_path_points(position: Vector2) -> Array[Vector2]:
	var closest_points: Array[Vector2] = []
	var shortest_distance := INF

	for path in get_tree().get_nodes_in_group("Path"):
		if not (path is Path2D):
			continue

		var curve = path.curve
		
		if curve.get_point_count() == 0:
			continue

		var distance = position.distance_to(path.global_position + curve.get_point_position(0))

		if distance < shortest_distance:
			shortest_distance = distance
			closest_points = get_path_global_points(path)

	return closest_points

func get_path_global_points(path: Path2D) -> Array[Vector2]:
	var points: Array[Vector2] = []

	for i in range(path.curve.get_point_count()):
		points.append(path.global_position + path.curve.get_point_position(i))

	return points

func start_wave():
	if wave_index >= number_of_waves:
		return
		
	var current_wave: Wave = wave_set.waves[wave_index]
	wave_already_finished = false
	
	notify_wave_started()
	
	spawn_timer = current_wave.interval
	enemy_data = current_wave.enemy_data
	wave_enemies_remaining = current_wave.count
	wave_index += 1

func notify_wave_finished():
	emit_signal("wave_finished")
	
func notify_wave_started():
	emit_signal("wave_started", wave_index)

func _on_enemy_died(enemy: EnemyLogic, attacker: Entity):
	wave_enemies_remaining -= 1
