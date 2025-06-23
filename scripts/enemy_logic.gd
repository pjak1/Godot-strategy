# EnemyLogic.gd
extends MovableEntity

class_name EnemyLogic

var valid_enemy_types = ["normal", "desert"]

@export var type: String = valid_enemy_types[0]
