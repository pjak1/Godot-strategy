extends Node2D

class_name Entity

@export var max_health: int = 100
@export var damage: int = 15

var current_health: int

signal health_updated(new_health: int, max_health: int)
signal delt_damage(target_position: Vector2)
signal died

func _ready():
	current_health = max_health
	
func take_damage(amount: int):
	current_health -= amount
	emit_health_update()

	if current_health <= 0:
		die()
		
func deal_damage(target):
	if target and target.is_inside_tree():
		if target.has_method("take_damage"):
			target.take_damage(damage)

	emit_signal("delt_damage", target.global_position if target else global_position)
	
func die():
	emit_signal("died") # Notify graphics that the enemy died
	queue_free() # Remove the logic node

func emit_health_update():
	emit_signal("health_updated", current_health, max_health)
