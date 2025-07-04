# EnemyLogic.gd
extends MovableEntity

class_name EnemyLogic

# === Exported Variables ===
@export var reward: int = 100

# === Runtime Variables ===
var type: String
var data: EnemyData

# === Public Methods ===

func initialize(enemy_data: EnemyData) -> void:
	data = enemy_data
	max_health = data.max_health
	current_health = data.max_health
	speed = data.speed
	type = data.type
	reward = data.reward
