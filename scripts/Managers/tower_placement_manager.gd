extends Node

class_name TowerPlacementManager

@export var money_path: NodePath
@export var tower_manager_path: NodePath
@export var bounds_validator : NodePath
@export var path_manager: NodePath

@onready var tower_manager = get_node(tower_manager_path)
@onready var money = get_node(money_path)
@onready var validator: PlacementValidator = $PlacementValidator

var tower_to_place: Node2D = null
var tower_scene: PackedScene = null

signal tower_placed(tower: Node2D)

func start_placing(scene: PackedScene):
	if tower_to_place:
		tower_to_place.queue_free()

	tower_scene = scene
	tower_to_place = tower_scene.instantiate()
	tower_to_place.enable_targeting = false

	if tower_to_place.cost <= money.get_current_money():
		tower_to_place.set_placement_state(true)
		add_child(tower_to_place)

func update_position(pos: Vector2):
	if tower_to_place:
		tower_to_place.global_position = pos

		var is_valid = validator.is_position_valid(pos)

		if "set_placement_state" in tower_to_place:
			tower_to_place.set_placement_state(is_valid)


func confirm(pos: Vector2):
	if not validator.is_position_valid(pos):
		return false

	tower_to_place.global_position = pos
	tower_to_place.enable_targeting = true
	tower_to_place.set_placement_state("confirmed")

	tower_manager.register(tower_to_place)
	money.spend_money(tower_to_place.cost)
	emit_signal("tower_placed", tower_to_place)

	tower_to_place = null
	return true

func cancel():
	if tower_to_place:
		tower_to_place.queue_free()
	tower_to_place = null

func is_placing() -> bool:
	return tower_to_place != null
