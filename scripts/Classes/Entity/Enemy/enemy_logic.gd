# EnemyLogic.gd
extends MovableEntity

class_name EnemyLogic

@export var reward: int = 100

var type: String
var data: EnemyData

func initialize(enemy_data: EnemyData):
	data = enemy_data
	max_health = data.max_health
	current_health = data.max_health
	speed = data.speed
	type = data.type
	reward = data.reward
