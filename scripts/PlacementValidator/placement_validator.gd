extends Node
class_name PlacementValidator

@export var tower_radius: float = 150.0
@export var path_radius: float = 180.0

var tower_placement_manager: Node = null
var bounds_validator: Node = null
var path_manager: Node = null
var tower_manager: Node = null

func _ready():
	tower_placement_manager = owner as TowerPlacementManager
	
	if not tower_placement_manager:
		push_error("Owner is not TowerPlacementManager!")
		return
		
	_set_path_manager()
	_set_tower_manager()
	_set_bounds_validator()

func is_position_valid(pos: Vector2) -> bool:
	return not bounds_validator.is_out_of_bounds(pos) \
		and not path_manager.is_near_path(pos, path_radius) \
		and not tower_manager.is_tower_near(pos, tower_radius)

func _set_bounds_validator():
	if tower_placement_manager.bounds_validator:
		var path = tower_placement_manager.bounds_validator
		
		if path is NodePath:
			bounds_validator = tower_placement_manager.get_node_or_null(path)
		else:
			push_warning("TowerPlacementManager.bounds_validator is not a valid NodePath")
	else:
		push_warning("TowerPlacementManager does not export bounds_validator")

func _set_path_manager():
	if tower_placement_manager.path_manager:
		var path = tower_placement_manager.path_manager
		
		if path is NodePath:
			path_manager = tower_placement_manager.get_node_or_null(path)
		else:
			push_warning("TowerPlacementManager.path_manager is not a valid NodePath")
	else:
		push_warning("TowerPlacementManager does not export path_manager")
		
func _set_tower_manager():
	if tower_placement_manager.tower_manager_path:
		var path = tower_placement_manager.tower_manager_path
		
		if path is NodePath:
			tower_manager = tower_placement_manager.get_node_or_null(path)
		else:
			push_warning("TowerPlacementManager.tower_manager_path is not a valid NodePath")
	else:
		push_warning("TowerPlacementManager does not export tower_manager_path")
