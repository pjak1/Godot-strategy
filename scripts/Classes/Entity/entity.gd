extends Node2D
class_name Entity

# === Exported Variables ===
@export var max_health: int = 100
@export var damage: int = 15

# === Runtime Variables ===
var current_health: int

# === Signals ===
signal health_updated(new_health: int, max_health: int)
signal delt_damage(target_position: Vector2)
signal died(target: Entity, attacker: Entity)

# === Lifecycle ===

func _ready() -> void:
	current_health = max_health

# === Public Methods ===

# Reduces health by damage amount and checks for death
func take_damage(amount: int, attacker: Entity) -> void:
	current_health -= amount
	_emit_health_update()

	if current_health <= 0:
		die(attacker)

# Deals damage to another entity if valid
func deal_damage(target: Entity) -> void:
	if target and target.is_inside_tree():
		if target.has_method("take_damage"):
			target.take_damage(damage, self)

	emit_signal("delt_damage", target.global_position if target else global_position)

# Handles entity death and notifies others
func die(attacker: Entity) -> void:
	emit_signal("died", self, attacker)
	queue_free()

# === Private Methods ===

# Emits current and maximum health values
func _emit_health_update() -> void:
	emit_signal("health_updated", current_health, max_health)
