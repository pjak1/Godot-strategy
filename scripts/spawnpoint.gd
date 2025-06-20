extends Node2D

@export var enemy_scene: PackedScene  # drag & drop Enemy.tscn v editoru
@export var spawn_interval: float = 5.0  # sekundy mezi spawnem
@export var max_enemies: int = 10  # kolik nepřátel může spawnout celkem, 0 = neomezeno
@export_enum("normal", "desert", "plane", "bomber_plane")
var enemy_type: String = "normal"
var enemies_spawned: int = 0
var spawn_timer := 0.0

func _process(delta):
	if max_enemies > 0 and enemies_spawned >= max_enemies:
		return  # limit splněn

	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_enemy()

func assign_closest_path(enemy):
	var all_paths = get_tree().get_nodes_in_group("Path")
	var closest_path_points: Array[Vector2] = []
	var closest_distance := INF

	for path in all_paths:
		if not path is Path2D:
			continue
		var curve: Curve2D = path.curve
		if curve.get_point_count() == 0:
			continue

		var first_point: Vector2 = curve.get_point_position(0) + path.global_position
		var distance: float = enemy.global_position.distance_to(first_point)

		if distance < closest_distance:
			closest_distance = distance
			closest_path_points.clear()
			for i in range(curve.get_point_count()):
				var point = curve.get_point_position(i) + path.global_position
				closest_path_points.append(point)

	if closest_path_points.size() > 0:
		enemy.set_path_points(closest_path_points)
		enemy.enable_movement = true
	else:
		push_warning("Nepřítel %s nemá přiřazenou žádnou cestu!" % enemy.name)

func spawn_enemy():
	if not enemy_scene:
		push_error("Nezadána scéna Enemy v spawnpointu!")
		return

	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.type = enemy_type
	enemy_instance.global_position = global_position

	assign_closest_path(enemy_instance)

	get_parent().add_child(enemy_instance)
	enemy_instance.add_to_group("Enemy")

	enemies_spawned += 1
