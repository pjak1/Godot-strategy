extends Node
class_name EnemyManager

signal enemy_killed(enemy: EnemyLogic, attacker: Entity)
signal enemy_has_reached_end(enemy: EnemyLogic)

var enemies: Dictionary = {}

func _ready():
	_connect_all_spawnpoints()

func _connect_all_spawnpoints():
	for spawner in get_tree().get_nodes_in_group("SpawnPoint"):
		if spawner.has_signal("enemy_spawned"):
			spawner.connect("enemy_spawned", _on_enemy_spawned)

func _on_enemy_spawned(enemy: EnemyLogic) -> void:
	enemies[enemy.get_instance_id()] = enemy
	enemy.connect("died", _on_enemy_died)
	enemy.entity_has_reached_end.connect(on_entity_has_reached_end)

func _on_enemy_died(enemy: EnemyLogic, attacker: Entity) -> void:
	enemies.erase(enemy.get_instance_id())
	emit_signal("enemy_killed", enemy, attacker)

func on_entity_has_reached_end(entity: MovableEntity):
	notify_enemy_has_reached_end(entity)

func notify_enemy_has_reached_end(enemy: EnemyLogic):
	emit_signal("enemy_has_reached_end", enemy)
