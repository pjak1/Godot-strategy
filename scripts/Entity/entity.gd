extends Node2D

class_name Entity

@export var max_health: int = 100
@export var damage: int = 15

var current_health: int

signal health_updated(new_health: int, max_health: int)
signal delt_damage(target_position: Vector2)
signal died(target: Entity, attacker: Entity)

func _ready():
	current_health = max_health
	
func take_damage(amount: int, attacker: Entity):
	current_health -= amount
	emit_health_update()

	if current_health <= 0:
		die(attacker)
		
func deal_damage(target: Entity):
	if target and target.is_inside_tree():
		if target.has_method("take_damage"):
			target.take_damage(damage, self)

	emit_signal("delt_damage", target.global_position if target else global_position)
	
func die(attacker: Entity):
	emit_signal("died", self, attacker)
	queue_free()

func emit_health_update():
	emit_signal("health_updated", current_health, max_health)
