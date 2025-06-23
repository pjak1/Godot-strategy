extends Entity

class_name TurretLogic

@export var rate_of_fire: float = 1.0
@export var range: float = 1000.0
@export var enable_targeting: bool = true
@export var angle_offset_deg: float = 87.0
@export var turret_graphics_path: NodePath = "TurretGraphics"
@export var barrel_node_name: String = "Barrel"
@export var targeted_group: String = "Enemy"

var fire_cooldown: float = 0.0
var current_target: Node2D = null
var fire_threshold := 0.10

signal target_angle_changed(new_angle: float)

var turret_graphics: Node = null

func _ready():
	fire_cooldown = 0.0
	turret_graphics = get_node_or_null(turret_graphics_path)

func _process(delta):
	fire_cooldown = max(fire_cooldown - delta, 0.0)
	
	if enable_targeting:
		current_target = find_nearest_enemy()
		if current_target:
			var direction = current_target.global_position - global_position
			var target_angle = direction.angle() + deg_to_rad(angle_offset_deg)
			
			emit_signal("target_angle_changed", target_angle)

			var current_barrel_rotation := 0.0
			if turret_graphics and turret_graphics.has_node(barrel_node_name):
				var barrel_node = turret_graphics.get_node(barrel_node_name)
				if barrel_node is Node2D:
					current_barrel_rotation = barrel_node.rotation
			
			var angle_diff = abs(angle_wrap(current_barrel_rotation - target_angle))

			if angle_diff < fire_threshold and fire_cooldown <= 0.0:
				deal_damage(current_target)
				fire_cooldown = 1.0 / rate_of_fire
		else:
			emit_signal("target_angle_changed", deg_to_rad(angle_offset_deg))

func find_nearest_enemy() -> Node2D:
	var nearest_enemy: Node2D = null
	var shortest_distance := INF

	for enemy in get_tree().get_nodes_in_group(targeted_group):
		if enemy == self:
			continue  # Přeskočíme sami sebe
		if enemy and enemy is Node2D:
			var distance = global_position.distance_to(enemy.global_position)
			if distance < shortest_distance and distance <= range:
				shortest_distance = distance
				nearest_enemy = enemy

	return nearest_enemy
	
func angle_wrap(angle):
	while angle > PI:
		angle -= TAU
	while angle < -PI:
		angle += TAU
	return angle

func set_range_debug(debug: bool):
	if turret_graphics == null:
		turret_graphics = get_node_or_null(turret_graphics_path)
	if turret_graphics and turret_graphics.has_method("set"):
		turret_graphics.set("show_range_debug", debug)
	else:
		push_warning("TurretGraphics not found or invalid when setting range debug")
