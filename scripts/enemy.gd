extends Area2D

class_name Enemy
const VALID_ENEMY_TYPES = ["normal", "desert", "plane", "bomber_plane"]

@export var type: String = "desert"
@export var speed: float = 100.0
@export var max_turn_speed = deg_to_rad(90)
@export var max_health: int = 100
@export var enable_movement: bool = true

var current_health: int
var path_points: Array[Vector2] = []
var current_point := 0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
	if not VALID_ENEMY_TYPES.has(type):
		push_error("Neplatný typ nepřítele: '%s'" % type)
		return
	current_health = max_health
	
	if type:
		sprite.animation = type
		sprite.frame = 0
		sprite.play()
	else:
		print("Animace '", type, "' neexistuje!")
	
	if path_points.size() > 0:
		var min_dist = INF
		var nearest_index = 0
		for i in range(path_points.size()):
			var dist = global_position.distance_to(path_points[i])
			if dist < min_dist:
				min_dist = dist
				nearest_index = i
		current_point = nearest_index

func _process(delta):
	if enable_movement and path_points.size() > 0:
		print(path_points.size())
		move_along_path(delta)

func rotate_towards_target(delta, target_pos: Vector2):
	var to_target = target_pos - global_position
	var desired_angle = to_target.angle()
	var angle_diff = wrapf(desired_angle - rotation, -PI, PI)
	var turn_amount = clamp(angle_diff, -max_turn_speed * delta, max_turn_speed * delta)
	rotation += turn_amount

func move_along_path(delta):
	if current_point >= path_points.size():
		queue_free()
		return

	var target = path_points[current_point]
	var distance_to_target = global_position.distance_to(target)

	if distance_to_target < 5.0:
		current_point += 1
		if current_point >= path_points.size():
			queue_free()
			return
		target = path_points[current_point]

	rotate_towards_target(delta, target)

	# Pohyb vpřed ve směru aktuální rotace
	var forward = Vector2(cos(rotation), sin(rotation))
	global_position += forward * speed * delta


func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	queue_free()
	
func set_path_points(points: Array[Vector2]):
	path_points = points
	if path_points.size() > 0:
		var min_dist = INF
		var nearest_index = 0
		for i in range(path_points.size()):
			var dist = global_position.distance_to(path_points[i])
			if dist < min_dist:
				min_dist = dist
				nearest_index = i
		current_point = nearest_index
