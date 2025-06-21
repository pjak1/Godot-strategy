extends Node2D

@export var enemy_logic_scene: PackedScene # Přetáhni EnemyLogic.tscn (nebo Enemy.tscn s EnemyLogic skriptem) sem v editoru
@export var spawn_interval: float = 5.0    # sekundy mezi spawnem
@export var max_enemies: int = 10        # kolik nepřátel může spawnout celkem, 0 = neomezeno
@export_enum("normal", "desert", "plane", "bomber_plane")
var enemy_type: String = "normal"

var enemies_spawned: int = 0
var spawn_timer := 0.0

func _process(delta):
	if max_enemies > 0 and enemies_spawned >= max_enemies:
		return # limit splněn

	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		spawn_enemy()

func assign_closest_path(enemy_logic_instance: EnemyLogic):
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
		var distance: float = enemy_logic_instance.global_position.distance_to(first_point)

		if distance < closest_distance:
			closest_distance = distance
			closest_path_points.clear()
			for i in range(curve.get_point_count()):
				var point = curve.get_point_position(i) + path.global_position
				closest_path_points.append(point)

	if closest_path_points.size() > 0:
		enemy_logic_instance.set_path_points(closest_path_points)
		enemy_logic_instance.enable_movement = true
	else:
		push_warning("Nepřítel %s nemá přiřazenou žádnou cestu!" % enemy_logic_instance.name)

func spawn_enemy():
	if not enemy_logic_scene:
		push_error("Nezadána scéna Enemy (logika) v spawnpointu! Ujisti se, že jsi přetáhl/a scénu obsahující EnemyLogic.")
		return

	var enemy_logic_instance: EnemyLogic = enemy_logic_scene.instantiate()
	enemy_logic_instance.type = enemy_type # Nastavení typu nepřítele
	enemy_logic_instance.global_position = global_position # Umístění nepřítele na pozici spawnpointu

	assign_closest_path(enemy_logic_instance) # Přiřazení cesty

	get_parent().add_child(enemy_logic_instance) # Přidání instance do scény
	enemy_logic_instance.add_to_group("Enemy") # Přidání do skupiny "Enemy" (pro případné globální reference)

	enemies_spawned += 1
