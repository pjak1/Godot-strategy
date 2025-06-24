extends Node2D

class_name Spawner

@export var enemy_logic_scene: PackedScene
@export var spawn_interval: float = 5.0
@export var max_enemies: int = 10 
@export_enum("normal", "desert", "plane", "bomber_plane")

var enemy_type: String = "normal"

var enemies_spawned: int = 0
var spawn_timer := 0.0

signal enemy_spawned

func _process(delta):
	if can_spawn():
		update_spawn_timer(delta)

func can_spawn() -> bool:
	return max_enemies <= 0 or enemies_spawned < max_enemies

func update_spawn_timer(delta: float) -> void:
	spawn_timer += delta
	
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_enemy()

func spawn_enemy() -> void:
	if not enemy_logic_scene:
		push_error("Enemy logic scene not set!")
		return

	var enemy = instantiate_enemy()
	
	assign_closest_path_to_enemy(enemy)
	add_enemy_to_scene(enemy)
	register_enemy(enemy)

func instantiate_enemy() -> EnemyLogic:
	var enemy: EnemyLogic = enemy_logic_scene.instantiate()
	
	enemy.type = enemy_type
	enemy.global_position = global_position
	return enemy

func assign_closest_path_to_enemy(enemy: EnemyLogic) -> void:
	var closest_path = find_closest_path_points(enemy.global_position)
	
	if closest_path.size() > 0:
		enemy.set_path_points(closest_path)
		enemy.enable_movement = true
	else:
		push_warning("Enemy %s does not have assigned path!" % enemy.name)

func find_closest_path_points(position: Vector2) -> Array[Vector2]:
	var closest_points: Array[Vector2] = []
	var shortest_distance := INF

	for path in get_tree().get_nodes_in_group("Path"):
		if path is Path2D:
			var curve = path.curve
			if curve.get_point_count() == 0:
				continue

			var first_point = path.global_position + curve.get_point_position(0)
			var distance = position.distance_to(first_point)

			if distance < shortest_distance:
				shortest_distance = distance
				closest_points.clear()
				for i in range(curve.get_point_count()):
					closest_points.append(path.global_position + curve.get_point_position(i))

	return closest_points

func add_enemy_to_scene(enemy: EnemyLogic) -> void:
	get_parent().add_child(enemy)
	enemy.add_to_group("Enemy")

func register_enemy(enemy: EnemyLogic) -> void:
	enemies_spawned += 1
	emit_signal("enemy_spawned", enemy)
