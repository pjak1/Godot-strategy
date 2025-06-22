extends Area2D

class_name TurretLogic

@export var rate_of_fire: float = 1.0         # Shots per second
@export var damage: int = 15                   # Damage dealt per shot
@export var range: float = 1000.0              # Maximum targeting range
@export var enable_targeting: bool = true     # Whether turret can target enemies
@export var angle_offset_deg: float = 87.0    # Angle offset for aiming adjustment in degrees

var fire_cooldown: float = 0.0                 # Timer for controlling rate of fire
var current_target: Node2D = null              # Currently targeted enemy

signal target_angle_changed(new_angle: float) # Signal emitted when turret aims at a new angle
signal shot(target_position: Vector2)         # Signal emitted when turret fires a shot

func _ready():
	# Initialize cooldown timer at start
	fire_cooldown = 0.0

func _process(delta):
	# Decrease cooldown timer by elapsed time, but don't go below zero
	fire_cooldown = max(fire_cooldown - delta, 0.0)
	
	if enable_targeting:
		# Find the closest enemy within range
		current_target = find_nearest_enemy()
		if current_target:
			# Calculate the direction vector to the target
			var direction = current_target.global_position - global_position
			# Calculate the angle to the target plus the offset (converted to radians)
			var target_angle = direction.angle() + deg_to_rad(angle_offset_deg)
			
			# Notify listeners about the new aiming angle
			emit_signal("target_angle_changed", target_angle)

			# Get current rotation of the turret's barrel graphic, if it exists
			var current_barrel_rotation = 0.0
			var turret_graphics_node = get_node_or_null("TurretGraphics")
			if turret_graphics_node and turret_graphics_node.has_node("Barrel"):
				current_barrel_rotation = turret_graphics_node.get_node("Barrel").rotation
			
			# Calculate the difference between current barrel angle and desired target angle,
			# using angle wrapping to handle shortest rotation direction
			var angle_diff = abs(angle_wrap(current_barrel_rotation - target_angle))
			var fire_threshold = 0.05  # Threshold angle difference to allow firing

			# Fire if barrel is sufficiently aligned and cooldown has elapsed
			if angle_diff < fire_threshold and fire_cooldown <= 0.0:
				shoot(current_target)
				fire_cooldown = 1.0 / rate_of_fire
		else:
			# If no target, reset turret angle to default offset angle
			emit_signal("target_angle_changed", deg_to_rad(angle_offset_deg))


func find_nearest_enemy() -> Node2D:
	# Finds the closest enemy Node2D within turret's range
	var nearest_enemy = null
	var shortest_distance = INF

	# Iterate over all nodes in "Enemy" group
	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy and enemy is Node2D:
			var distance = global_position.distance_to(enemy.global_position)
			# Check if enemy is closer and within range
			if distance < shortest_distance and distance <= range:
				shortest_distance = distance
				nearest_enemy = enemy

	return nearest_enemy

func shoot(target):
	# Applies damage to the target if possible and emits a shot signal
	if target and target.is_inside_tree():
		if target.has_method("take_damage"):
			target.take_damage(damage)

	emit_signal("shot", target.global_position if target else global_position)

func angle_wrap(angle):
	# Wraps an angle in radians to the range [-PI, PI]
	while angle > PI:
		angle -= TAU
	while angle < -PI:
		angle += TAU
	return angle
