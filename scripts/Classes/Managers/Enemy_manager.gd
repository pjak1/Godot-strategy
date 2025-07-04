extends Node
class_name EnemyManager

# === Signals ===
signal enemy_killed(enemy: EnemyLogic, attacker: Entity)
signal enemy_has_reached_end(enemy: EnemyLogic)

# === Runtime Variables ===
var enemies: Dictionary = {}

# === Lifecycle ===

func _ready() -> void:
	_connect_all_spawnpoints()

# === Private Methods ===

# Connects to enemy_spawned signal on all spawn points
func _connect_all_spawnpoints() -> void:
	for spawner in get_tree().get_nodes_in_group("SpawnPoint"):
		if spawner.has_signal("enemy_spawned"):
			spawner.enemy_spawned.connect(_on_enemy_spawned)

# Handles when a new enemy is spawned
func _on_enemy_spawned(enemy: EnemyLogic) -> void:
	enemies[enemy.get_instance_id()] = enemy
	enemy.died.connect(_on_enemy_died)
	enemy.entity_has_reached_end.connect(_on_entity_has_reached_end)

# Handles when an enemy is killed
func _on_enemy_died(enemy: EnemyLogic, attacker: Entity) -> void:
	enemies.erase(enemy.get_instance_id())
	emit_signal("enemy_killed", enemy, attacker)

# Handles when an enemy reaches the end of its path
func _on_entity_has_reached_end(entity: MovableEntity) -> void:
	_notify_enemy_has_reached_end(entity)

# === Helper Methods ===

# Emits signal for enemies that reached the end
func _notify_enemy_has_reached_end(enemy: EnemyLogic) -> void:
	emit_signal("enemy_has_reached_end", enemy)
