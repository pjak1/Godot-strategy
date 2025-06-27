extends Node

class_name TowerPlacementManager

signal tower_placed(tower: Node2D)

@export var money_node: NodePath
@export var tilemap_node: NodePath
@export var tower_manager_node: NodePath
@export var path_manager_node: NodePath

const COLOR_VALID = Color(1, 1, 1, 0.5)
const COLOR_INVALID = Color(1, 0.3, 0.3, 0.7)
const COLOR_CONFIRMED = Color(1, 1, 1)

const TOWER_RADIUS = 150.0
const PATH_RADIUS = 180.0

var money
var tilemap
var tower_manager
var path_manager

var tower_instances: Dictionary = {}
var tower_to_place: Node2D = null
var tower_scene: PackedScene = null

func _ready():
	money = get_node(money_node)
	tilemap = get_node(tilemap_node)
	tower_manager = get_node(tower_manager_node)
	path_manager = get_node(path_manager_node)

func start_placing(scene: PackedScene):
	if tower_to_place:
		tower_to_place.queue_free()
	tower_scene = scene
	tower_to_place = tower_scene.instantiate()
	
	if tower_to_place.cost <= money.get_current_money():
		tower_to_place.modulate = COLOR_VALID
		tower_to_place.set_range_debug(true)
		add_child(tower_to_place)

func update_position(pos: Vector2):
	if tower_to_place:
		tower_to_place.global_position = pos
		tower_to_place.modulate = COLOR_VALID if is_position_valid(pos) else COLOR_INVALID

func confirm(pos: Vector2):
	if not is_position_valid(pos):
		return false

	tower_to_place.global_position = pos
	tower_to_place.modulate = COLOR_CONFIRMED
	tower_to_place.enable_targeting = true
	tower_to_place.set_range_debug(false)

	tower_manager.register(tower_to_place)
	money.spend_money(tower_to_place.cost)

	emit_signal("tower_placed", tower_to_place)
	tower_to_place = null
	return true

func cancel():
	if tower_to_place:
		tower_to_place.queue_free()
	tower_to_place = null

func is_position_valid(pos: Vector2) -> bool:
	return not is_out_of_bounds(pos) \
		and not path_manager.is_near_path(pos, PATH_RADIUS) \
		and not tower_manager.is_tower_near(pos, TOWER_RADIUS)

func is_out_of_bounds(pos: Vector2) -> bool:
	var used_rect: Rect2 = tilemap.get_used_rect()
	var top_left = tilemap.map_to_local(used_rect.position)
	var bottom_right = tilemap.map_to_local(used_rect.position + used_rect.size)
	var bounds_rect = Rect2(top_left, bottom_right - top_left)
	return not bounds_rect.has_point(pos)

func is_placing() -> bool:
	return tower_to_place != null
