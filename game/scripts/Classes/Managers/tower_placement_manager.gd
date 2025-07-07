extends Node2D
class_name TowerPlacementManager

# === Exported Variables ===
@export var money_path: NodePath
@export var tower_manager_path: NodePath
@export var bounds_validator_path: NodePath
@export var path_manager_path: NodePath
@export var tower_radius: float = 150.0
@export var path_radius: float = 180.0

# === Node References ===
@onready var tower_manager: Node = get_node(tower_manager_path)
@onready var money: Node = get_node(money_path)
@onready var bounds_validator: Node = get_node(bounds_validator_path)
@onready var path_manager: Node = get_node(path_manager_path)

# === Runtime Variables ===
var tower_to_place: Node2D = null
var tower_scene: PackedScene = null
var is_now_placing: bool = false
var ready_for_confirm: bool = false

# === Signals ===
signal tower_placed(tower: Node2D)

# === Public Methods ===

func start_placing(scene: PackedScene) -> void:
	if is_now_placing:
		return

	if tower_to_place:
		tower_to_place.queue_free()
		tower_to_place = null

	is_now_placing = true
	ready_for_confirm = false
	tower_scene = scene
	tower_to_place = tower_scene.instantiate()
	# Disable targeting while placing
	tower_to_place.enable_targeting = false

	if tower_to_place.cost <= money.get_current_money():
		var mouse_pos: Vector2 = get_global_mouse_position()

		tower_to_place.set_placement_state(true)
		update_position(mouse_pos)
		call_deferred("add_child", tower_to_place)
		ready_for_confirm = true
	else:
		tower_to_place.queue_free()
		tower_to_place = null
		is_now_placing = false
		ready_for_confirm = false

func update_position(pos: Vector2) -> void:
	if tower_to_place:
		var is_valid: bool = is_position_valid(pos)
		tower_to_place.global_position = pos
		tower_to_place.set_placement_state(is_valid)

func confirm(pos: Vector2) -> bool:
	if not ready_for_confirm:
		return false

	if tower_to_place == null:
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

func cancel() -> void:
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
