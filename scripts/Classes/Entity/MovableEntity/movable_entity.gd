extends Entity
class_name MovableEntity

# === Exported Variables ===
@export var speed: float = 100.0
@export var max_turn_speed: float = deg_to_rad(90)
@export var enable_movement: bool = true

# === Runtime Variables ===
var path_points: Array[Vector2] = []
var current_point: int = 0

# === Signals ===
signal entity_has_reached_end(entity: MovableEntity)

# === Lifecycle ===

func _ready() -> void:
	super._ready()
	select_nearest_path_point()

func _process(delta: float) -> void:
	if enable_movement and path_points.size() > 0:
		move_along_path(delta)

# === Movement Logic ===

# Move entity toward the next path point
func move_along_path(delta: float) -> void:
	while current_point < path_points.size() and is_close_to_target(path_points[current_point]):
		current_point += 1

	if has_reached_end_of_path():
		notify_entity_has_reached_end()
		die(null)
		return

	var target: Vector2 = path_points[current_point]
	turn_towards_target(delta, target)
	move_forward(delta)

# Rotate entity to face toward the current target
func turn_towards_target(delta: float, target_pos: Vector2) -> void:
	var desired_angle: float = (target_pos - global_position).angle()
	var angle_diff: float = wrapf(desired_angle - rotation, -PI, PI)
	var turn_amount: float = clamp(angle_diff, -max_turn_speed * delta, max_turn_speed * delta)
	rotation += turn_amount

# Move entity forward in its current facing direction
func move_forward(delta: float) -> void:
	var forward: Vector2 = Vector2(cos(rotation), sin(rotation))
	global_position += forward * speed * delta

# === Checks ===

# Returns true if the entity is close enough to a target point
func is_close_to_target(target: Vector2) -> bool:
	return global_position.distance_to(target) < 5.0

# Returns true if all path points have been reached
func has_reached_end_of_path() -> bool:
	return current_point >= path_points.size()

# === Public API ===

# Sets the path and picks the closest point as starting point
func set_path_points(points: Array[Vector2]) -> void:
	path_points = points
	select_nearest_path_point()

# === Helpers ===

# Select the closest path point to the entity's current position
func select_nearest_path_point() -> void:
	if path_points.is_empty():
		current_point = 0
		return

	var min_dist: float = INF
	var nearest_index: int = 0

	for i in range(path_points.size()):
		var dist: float = global_position.distance_to(path_points[i])
		if dist < min_dist:
			min_dist = dist
			nearest_index = i

	current_point = nearest_index

# Emit a signal to notify that the path has been completed
func notify_entity_has_reached_end() -> void:
	emit_signal("entity_has_reached_end", self)
