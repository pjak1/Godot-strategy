extends Entity

class_name MovableEntity

@export var speed: float = 100.0
@export var max_turn_speed = deg_to_rad(90)
@export var enable_movement: bool = true

var path_points: Array[Vector2] = []
var current_point := 0

func _ready():
	super._ready()
	select_nearest_path_point()

func _process(delta):
	if enable_movement and path_points.size() > 0:
		move_along_path(delta)

func move_along_path(delta: float):
	while current_point < path_points.size() and is_close_to_target(path_points[current_point]):
		current_point += 1

	if has_reached_end_of_path():
		die(null)
		return

	var target = path_points[current_point]
	turn_towards_target(delta, target)
	move_forward(delta)


func turn_towards_target(delta: float, target_pos: Vector2):
	var desired_angle = (target_pos - global_position).angle()
	var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
	var turn_amount = clamp(angle_diff, -max_turn_speed * delta, max_turn_speed * delta)
	rotation += turn_amount

func move_forward(delta: float):
	var forward = Vector2(cos(rotation), sin(rotation))
	global_position += forward * speed * delta

func is_close_to_target(target: Vector2) -> bool:
	return global_position.distance_to(target) < 5.0

func has_reached_end_of_path() -> bool:
	return current_point >= path_points.size()

func set_path_points(points: Array[Vector2]):
	path_points = points
	select_nearest_path_point()

func select_nearest_path_point():
	if path_points.is_empty():
		current_point = 0
		return

	var min_dist = INF
	var nearest_index = 0

	for i in range(path_points.size()):
		var dist = global_position.distance_to(path_points[i])
		if dist < min_dist:
			min_dist = dist
			nearest_index = i

	current_point = nearest_index
