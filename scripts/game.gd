extends Node2D

@onready var tower_inventory := $TowerInventory
@onready var tower_container := $TowerContainer
@onready var tilemap := $TileMapLayer
@onready var money := $Money

# Constants
const PATH_BLOCK_RADIUS: float = 180.0
const TOWER_BLOCK_RADIUS: float = 150.0
const tower_to_place_ALPHA: float = 0.5
const tower_to_place_ALPHA_INVALID: float = 0.7

const COLOR_VALID: Color = Color(1, 1, 1, tower_to_place_ALPHA)
const COLOR_INVALID: Color = Color(1, 0.3, 0.3, tower_to_place_ALPHA_INVALID)
const COLOR_CONFIRMED: Color = Color(1, 1, 1, 1)

const ENEMY_KILLED_REWARD: int = 100

# Variables
var selected_tower_scene: PackedScene
var tower_to_place_scene: PackedScene = null
var tower_to_place_instance: Node2D = null
var tower_instances: Dictionary = {}

var enemies: Dictionary = {}
var spawnpoints: Dictionary = {}

var paths_points: Array = []

signal tower_selected(tower_scene: PackedScene)

func _ready():
	connect_inventory_signal()
	load_paths_points()
	load_spawnpoints()

func connect_inventory_signal():
	tower_inventory.connect("tower_selected", _on_tower_selected)

func connect_enemy_spawned_signal(spawnpoint: Spawner):
	spawnpoint.connect("enemy_spawned", _on_enemy_spawned)
	
func load_spawnpoints():
	spawnpoints.clear()
	for node in get_tree().get_nodes_in_group("SpawnPoint"):
		spawnpoints[node.get_instance_id()] = node
		node.connect("enemy_spawned", _on_enemy_spawned)

func load_paths_points():
	paths_points.clear()
	for path in get_tree().get_nodes_in_group("Path"):
		if path is Path2D:
			var points = []
			var curve = path.curve
			for i in range(curve.get_point_count()):
				points.append(path.to_global(curve.get_point_position(i)))
			paths_points.append(points)

func _input(event):
	if tower_to_place_instance:
		handle_placing_input(event)

func handle_placing_input(event):
	var pos = get_global_mouse_position()
	if event is InputEventMouseMotion:
		update_tower_to_place_position(pos)
		update_tower_to_place_color(pos)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_place_tower(pos)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		cancel_tower_placement()

func update_tower_to_place_position(pos: Vector2):
	tower_to_place_instance.global_position = pos

func update_tower_to_place_color(pos: Vector2):
	tower_to_place_instance.modulate = COLOR_VALID if is_position_buildable(pos) else COLOR_INVALID

func try_place_tower(pos: Vector2):
	if is_position_buildable(pos):
		confirm_tower_placement()
	else:
		print("Cannot build too close to road or other towers!")

func confirm_tower_placement():
	tower_to_place_instance.modulate = COLOR_CONFIRMED
	tower_to_place_instance.enable_targeting = true
	tower_to_place_instance.set_range_debug(false)
	tower_to_place_instance.add_to_group("Tower")

	# připojit signál a uložit do dictionary
	tower_to_place_instance.connect("died", Callable(self, "_on_tower_died").bind(tower_to_place_instance))
	tower_instances[tower_to_place_instance.get_instance_id()] = tower_to_place_instance
	
	money.spend_money(tower_to_place_instance.cost)
		
	tower_to_place_instance = null
	tower_to_place_scene = null
	set_process_input(false)

func cancel_tower_placement():
	tower_to_place_instance.queue_free()
	tower_to_place_instance = null
	tower_to_place_scene = null
	set_process_input(false)

func point_to_segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var t = clamp((p - a).dot(ab) / ab.length_squared(), 0, 1)
	var projection = a + t * ab
	return p.distance_to(projection)

func is_position_buildable(pos: Vector2) -> bool:
	return not is_outside_of_bounds(pos) and not is_near_path(pos) and not is_tower_too_close(pos)

func is_near_path(pos: Vector2) -> bool:
	for points in paths_points:
		for i in range(points.size() - 1):
			var dist = point_to_segment_distance(pos, points[i], points[i + 1])
			if dist < PATH_BLOCK_RADIUS:
				return true
	return false

func is_tower_too_close(pos: Vector2) -> bool:
	for tower in tower_instances.values():
		if tower.global_position.distance_to(pos) < TOWER_BLOCK_RADIUS:
			return true
	return false

func is_outside_of_bounds(pos: Vector2) -> bool:
	# Získáme hranice mapy
	var used_rect: Rect2 = tilemap.get_used_rect()
	var cell_size: Vector2 = tilemap.tile_set.tile_size
	
	# Spočítáme globální hranice mapy
	var top_left = tilemap.map_to_local(used_rect.position)
	var bottom_right = tilemap.map_to_local(used_rect.position + used_rect.size)

	var bounds_rect = Rect2(top_left, bottom_right - top_left)
	
	return not bounds_rect.has_point(pos)
	

func _on_tower_selected(tower_scene: PackedScene):
	place_tower(tower_scene)

func place_tower(tower_scene: PackedScene):
	tower_to_place_scene = tower_scene
	tower_to_place_instance = tower_to_place_scene.instantiate()
	
	if money.money_amount >= tower_to_place_instance.cost:
		tower_to_place_instance.enable_targeting = false
		tower_to_place_instance.modulate = COLOR_VALID
		tower_to_place_instance.set_range_debug(true)
		add_child(tower_to_place_instance)
		tower_to_place_instance.global_position = get_global_mouse_position()
		set_process_input(true)
	else:
		tower_to_place_instance.queue_free()
		tower_to_place_instance = null
		tower_to_place_scene = null

func _on_tower_died(tower: Node2D):
	var id = tower.get_instance_id()
	if tower_instances.has(id):
		tower_instances.erase(id)

func _on_enemy_spawned(enemy: EnemyLogic):
	enemies[enemy.get_instance_id()] = enemy
	enemy.connect("died", _on_enemy_died)
	
func _on_enemy_died(enemy: EnemyLogic):
	var id = enemy.get_instance_id()
	if enemies.has(id):
		enemies.erase(id)
		money.add_money(ENEMY_KILLED_REWARD)
