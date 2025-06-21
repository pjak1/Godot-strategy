extends Area2D

class_name TurretLogic

@export var rate_of_fire: float = 1.0
@export var damage: int = 15
@export var range: float = 1000.0
@export var enable_targeting: bool = true
@export var angle_offset_deg: float = 87.0

var fire_cooldown: float = 0.0
var current_target: Node2D = null

signal target_angle_changed(new_angle: float)
signal shot(target_position: Vector2)

func _ready():
	fire_cooldown = 0.0

func _process(delta):
	fire_cooldown = max(fire_cooldown - delta, 0.0)
	
	if enable_targeting:
		current_target = find_nearest_enemy()
		if current_target:
			var direction = current_target.global_position - global_position
			var target_angle = direction.angle() + deg_to_rad(angle_offset_deg)
			
			emit_signal("target_angle_changed", target_angle)

			var current_barrel_rotation = 0.0
			var turret_graphics_node = get_node_or_null("TurretGraphics")
			if turret_graphics_node and turret_graphics_node.has_node("Barrel"):
				current_barrel_rotation = turret_graphics_node.get_node("Barrel").rotation
			
			var angle_diff = abs(angle_wrap(current_barrel_rotation - target_angle))
			var fire_threshold = 0.05

			if angle_diff < fire_threshold and fire_cooldown <= 0.0:
				shoot(current_target)
				fire_cooldown = 1.0 / rate_of_fire
		else:
			emit_signal("target_angle_changed", deg_to_rad(angle_offset_deg))


func find_nearest_enemy() -> Node2D:
	var nearest_enemy = null
	var shortest_distance = INF

	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy and enemy is Node2D:
			var distance = global_position.distance_to(enemy.global_position)
			if distance < shortest_distance and distance <= range:
				shortest_distance = distance
				nearest_enemy = enemy

	return nearest_enemy

func shoot(target):
	if target and target.is_inside_tree():
		if target.has_method("take_damage"):
			target.take_damage(damage)

	emit_signal("shot", target.global_position if target else global_position)

func angle_wrap(angle):
	while angle > PI:
		angle -= TAU
	while angle < -PI:
		angle += TAU
	return angle
