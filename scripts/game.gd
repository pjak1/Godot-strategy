extends Node2D

@onready var tower_inventory := $TowerInventory
@onready var tower_container := $TowerContainer
@onready var tilemap := $TileMapLayer

# Constants for blocking radius and colors
const PATH_BLOCK_RADIUS: float = 180.0 # Minimal tower distance from roads
const TOWER_BLOCK_RADIUS: float = 150.0 # Minimal distance between towers
const tower_to_place_ALPHA: float = 0.5
const tower_to_place_ALPHA_INVALID: float = 0.7

const COLOR_VALID: Color = Color(1, 1, 1, tower_to_place_ALPHA) # Semi-transparent white (valid placement)
const COLOR_INVALID: Color = Color(1, 0.3, 0.3, tower_to_place_ALPHA_INVALID) # Semi-transparent red (invalid placement)
const COLOR_CONFIRMED: Color = Color(1, 1, 1, 1) # Opaque white (confirmed placement)

# Variables for currently selected tower and towers placed on the map
var selected_tower_scene: PackedScene
var tower_to_place_scene: PackedScene = null
var tower_to_place_instance: Node2D = null
var tower_scenes : Array = []

# Stores points of all Path2D paths in global coordinates
var paths_points: Array = []

signal tower_selected(tower_scene: PackedScene)

func _ready():
	connect_inventory_signal()
	load_paths_points()

# Connect inventory's tower_selected signal to local handler
func connect_inventory_signal():
	tower_inventory.connect("tower_selected", Callable(self, "_on_tower_selected"))

# Load global points of all Path2D nodes for path blocking logic
func load_paths_points():
	paths_points.clear()
	for path in get_tree().get_nodes_in_group("Path"):
		if path is Path2D:
			var points = []
			var curve = path.curve
			for i in range(curve.get_point_count()):
				points.append(path.to_global(curve.get_point_position(i)))
			paths_points.append(points)

# Input handler for placing tower instance
func _input(event):
	if tower_to_place_instance:
		handle_placing_input(event)

# Process input events related to tower placement
func handle_placing_input(event):
	var pos = get_global_mouse_position()
	if event is InputEventMouseMotion:
		update_tower_to_place_position(pos)
		update_tower_to_place_color(pos)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		try_place_tower(pos)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		cancel_tower_placement()

# Update the position of the tower preview to follow the mouse
func update_tower_to_place_position(pos: Vector2):
	tower_to_place_instance.global_position = pos

# Update the tower preview color based on whether the position is valid
func update_tower_to_place_color(pos: Vector2):
	if is_position_buildable(pos):
		tower_to_place_instance.modulate = COLOR_VALID
	else:
		tower_to_place_instance.modulate = COLOR_INVALID

# Attempt to place tower at given position if valid
func try_place_tower(pos: Vector2):
	if is_position_buildable(pos):
		confirm_tower_placement()
	else:
		print("Cannot build too close to road or other towers!")

# Finalize tower placement: make tower fully visible and enable targeting
func confirm_tower_placement():
	tower_to_place_instance.modulate = COLOR_CONFIRMED
	tower_to_place_instance.enable_targeting = true
	tower_scenes.append(tower_to_place_instance)
	tower_to_place_instance = null
	tower_to_place_scene = null
	set_process_input(false)

# Cancel tower placement and remove preview instance
func cancel_tower_placement():
	tower_to_place_instance.queue_free()
	tower_to_place_instance = null
	tower_to_place_scene = null
	set_process_input(false)

# Calculate shortest distance from point p to segment defined by points a and b
func point_to_segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var t = clamp((p - a).dot(ab) / ab.length_squared(), 0, 1)
	var projection = a + t * ab
	return p.distance_to(projection)

# Check if a tower can be built at given position
func is_position_buildable(pos: Vector2) -> bool:
	if is_near_path(pos):
		return false
	if is_tower_too_close(pos):
		return false
	return true

# Check if position is too close to any path (road)
func is_near_path(pos: Vector2) -> bool:
	for points in paths_points:
		for i in range(points.size() - 1):
			var dist = point_to_segment_distance(pos, points[i], points[i+1])
			if dist < PATH_BLOCK_RADIUS:
				return true
	return false

# Check if position is too close to any existing tower
func is_tower_too_close(pos: Vector2) -> bool:
	for tower in tower_scenes:
		if tower.global_position.distance_to(pos) < TOWER_BLOCK_RADIUS:
			return true
	return false

# Signal handler called when a tower is selected from the inventory
func _on_tower_selected(tower_scene: PackedScene):
	place_tower(tower_scene)

# Initialize placing a tower instance and show semi-transparent preview
func place_tower(tower_scene: PackedScene):
	tower_to_place_scene = tower_scene
	tower_to_place_instance = tower_to_place_scene.instantiate()
	tower_to_place_instance.enable_targeting = false
	tower_to_place_instance.modulate = COLOR_VALID
	add_child(tower_to_place_instance)
	tower_to_place_instance.global_position = get_global_mouse_position()
	set_process_input(true)
