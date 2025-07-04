extends Node2D

class_name TowerPlacementManager

@export var money_path: NodePath
@export var tower_manager_path: NodePath
@export var bounds_validator_path : NodePath
@export var path_manager_path: NodePath
@export var tower_radius: float = 150.0
@export var path_radius: float = 180.0

@onready var tower_manager = get_node(tower_manager_path)
@onready var money = get_node(money_path)
@onready var bounds_validator = get_node(bounds_validator_path)
@onready var path_manager = get_node(path_manager_path)

var tower_to_place: Node2D = null
var tower_scene: PackedScene = null
var is_now_placing: bool = false
var ready_for_confirm: bool = false

signal tower_placed(tower: Node2D)

func start_placing(scene: PackedScene):
	if is_now_placing:
		return
	
	if tower_to_place:
		tower_to_place.queue_free()
		tower_to_place = null
		
	is_now_placing = true
	ready_for_confirm = false  # zatím ne připraveno
	tower_scene = scene
	tower_to_place = tower_scene.instantiate()
	tower_to_place.enable_targeting = false

	if tower_to_place.cost <= money.get_current_money():
		tower_to_place.set_placement_state(true)
		var mouse_pos = get_global_mouse_position()
		update_position(mouse_pos)
		call_deferred("add_child", tower_to_place)
		# až po přidání věže na scénu je připravena k potvrzení
		ready_for_confirm = true
	else:
		# pokud nemáme peníze, zrušíme pokládání
		tower_to_place.queue_free()
		tower_to_place = null
		is_now_placing = false
		ready_for_confirm = false

func update_position(pos: Vector2):
	if tower_to_place:
		var is_valid = is_position_valid(pos)
		tower_to_place.global_position = pos
		tower_to_place.set_placement_state(is_valid)

func confirm(pos: Vector2) -> bool:
	if not ready_for_confirm:
		print("❗ Věž není připravena k položení.")
		return false
	
	if tower_to_place == null:
		print("❗ tower_to_place je null v confirm.")
		return false

	if not is_position_valid(pos) or not is_now_placing:
		return false

	tower_to_place.global_position = pos
	tower_to_place.enable_targeting = true
	tower_to_place.set_placement_state("confirmed")

	tower_manager.register(tower_to_place)
	money.spend_money(tower_to_place.cost)
	emit_signal("tower_placed", tower_to_place)

	tower_to_place = null
	is_now_placing = false
	ready_for_confirm = false
	return true

func cancel():
	if tower_to_place:
		tower_to_place.queue_free()
		
	tower_to_place = null
	is_now_placing = false
	ready_for_confirm = false

func is_placing() -> bool:
	return is_now_placing

func is_position_valid(pos: Vector2) -> bool:
	return not bounds_validator.is_out_of_bounds(pos) \
		and not path_manager.is_near_path(pos, path_radius) \
		and not tower_manager.is_tower_near(pos, tower_radius)
