extends Entity

class_name TurretLogic

@export var rate_of_fire: float = 1.0
@export var range: float = 1000.0
@export var enable_targeting: bool = true
@export var angle_offset_deg: float = 87.0
@export var targeted_groups: Array[String] = ["Enemy"]
@export var cost: int = 100

var fire_cooldown: float = 0.0
var current_target: Node2D = null
var barrel_angle: float = 0.0
var fire_threshold := 0.15

signal target_angle_changed(new_angle: float)
signal fire(target_position: Vector2)
signal range_changed(new_range: float)
signal placement_state_changed(state: String)

func _ready():
	super._ready()
	fire_cooldown = 0.0
	emit_signal("range_changed", range)

func _process(delta):
	update_fire_cooldown(delta)
	if enable_targeting:
		handle_targeting()

func update_fire_cooldown(delta: float) -> void:
	fire_cooldown = max(fire_cooldown - delta, 0.0)

func handle_targeting():
	current_target = find_nearest_enemy()
	if current_target:
		handle_target_found()
	else:
		handle_no_target()

func handle_target_found():
	var angle_to_target = compute_target_angle(current_target.global_position)
	emit_signal("target_angle_changed", angle_to_target)

	if is_barrel_aligned(angle_to_target) and can_fire():
		fire_at_target()

func handle_no_target():
	var idle_angle = deg_to_rad(angle_offset_deg)
	emit_signal("target_angle_changed", idle_angle)

func compute_target_angle(target_pos: Vector2) -> float:
	var dir = target_pos - global_position
	return dir.angle() + deg_to_rad(angle_offset_deg)

func is_barrel_aligned(target_angle: float) -> bool:
	var angle_diff = abs(angle_wrap(barrel_angle - target_angle))
	return angle_diff < fire_threshold

func can_fire() -> bool:
	return fire_cooldown <= 0.0

func fire_at_target():
	emit_signal("fire", current_target.global_position)
	deal_damage(current_target)
	fire_cooldown = 1.0 / rate_of_fire

func find_nearest_enemy() -> Node2D:
	var nearest: Node2D = null
	var shortest := INF

	for group in targeted_groups:
		for enemy in get_tree().get_nodes_in_group(group):
			if enemy == self:
				continue
			if enemy is Node2D:
				var dist = global_position.distance_to(enemy.global_position)
				if dist < shortest and dist <= range:
					shortest = dist
					nearest = enemy

	return nearest

func update_barrel_angle(angle: float):
	barrel_angle = angle

func angle_wrap(angle: float) -> float:
	while angle > PI:
		angle -= TAU
	while angle < -PI:
		angle += TAU
	return angle

func set_placement_state(state_or_valid):
	var state := ""

	if typeof(state_or_valid) == TYPE_BOOL:
		state = "valid" if state_or_valid else "invalid"
	elif typeof(state_or_valid) == TYPE_STRING:
		state = state_or_valid
	else:
		push_warning("Invalid argument passed to set_placement_state")
		return

	emit_signal("placement_state_changed", state)
