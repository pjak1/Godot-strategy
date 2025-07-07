extends Node

class_name PlayerHealthLogic

# === Exported Variables ===
@export var max_lives: int = 5
@export var enemy_manager_path: NodePath

# === Onready Variables ===
@onready var enemy_manager: EnemyManager = get_node(enemy_manager_path)

# === Runtime Variables ===
var current_lives: int

# === Signals ===
signal lives_changed(current: int, max: int)
signal game_over()

# === Lifecycle ===

func _ready() -> void:
	enemy_manager.enemy_has_reached_end.connect(on_enemy_reached_end)
	current_lives = max_lives
	notify_lives_changed()

# === Public Methods ===

func on_enemy_reached_end(entity: MovableEntity) -> void:
	remove_life()

func remove_life(amount: int = 1) -> void:
	current_lives -= amount
	notify_lives_changed()

	if current_lives <= 0:
		notify_game_over()

func get_remaining_lives() -> int:
	return current_lives

# === Helper Methods ===

func notify_game_over() -> void:
	emit_signal("game_over")

func notify_lives_changed() -> void:
	emit_signal("lives_changed", current_lives, max_lives)
