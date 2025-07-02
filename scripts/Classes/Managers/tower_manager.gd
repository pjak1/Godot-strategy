extends Node

class_name TowerManager

var towers: Dictionary = {}

func register(tower: Node2D) -> void:
	towers[tower.get_instance_id()] = tower
	tower.add_to_group("Tower")
	tower.connect("died", Callable(self, "_on_tower_died").bind(tower))

func unregister(tower: Node2D) -> void:
	var id = tower.get_instance_id()
	if towers.has(id):
		towers.erase(id)

func _on_tower_died(tower: Node2D) -> void:
	unregister(tower)

func is_tower_near(pos: Vector2, radius: float) -> bool:
	for tower in towers.values():
		if tower.global_position.distance_to(pos) < radius:
			return true
	return false
