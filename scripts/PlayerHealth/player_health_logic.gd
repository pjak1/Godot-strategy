extends Node

class_name PlayerHealthLogic

@export var max_lives: int = 5
@export var enemy_manager_path: NodePath

@onready var enemy_manager: EnemyManager = get_node(enemy_manager_path)

var current_lives: int

signal lives_changed(current: int, max: int)
signal game_over()

func _ready():
	enemy_manager.enemy_has_reached_end.connect(on_enemy_reached_end)
	current_lives = max_lives
	notify_lives_changed()

func on_enemy_reached_end(entity: MovableEntity):
	remove_life()

func remove_life(amount: int = 1):
	current_lives -= amount
	notify_lives_changed()

	if current_lives <= 0:
		notify_game_over()

func notify_game_over():
	emit_signal("game_over")

func notify_lives_changed():
	emit_signal("lives_changed", current_lives, max_lives)
