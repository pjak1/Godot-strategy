# EnemyGraphics.gd
extends Node2D

class_name EnemyGraphics

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_logic: EnemyLogic = get_parent()
var LifeBarScene = preload("res://scenes//lifebar.tscn")
var life_bar: ProgressBar = null

	
func _ready():
	enemy_logic.health_updated.connect(update_life_bar)
	enemy_logic.died.connect(on_enemy_died)

	# Initialize sprite animation based on logic's type
	if enemy_logic.type:
		sprite.animation = enemy_logic.type
		sprite.frame = 0
		sprite.play()
	else:
		print("Animace '", enemy_logic.type, "' neexistuje!")

	# Instantiate and set up the life bar
	var life_bar_instance = LifeBarScene.instantiate()
	add_child(life_bar_instance)
	life_bar_instance.position = Vector2(-50, -80)
	life_bar_instance.set_max_health(enemy_logic.max_health)
	life_bar_instance.update_health(enemy_logic.current_health)
	life_bar = life_bar_instance

func update_life_bar(new_health: int, max_health: int):
	if life_bar:
		life_bar.update_health(new_health)

func on_enemy_died():
	# Handle any death animations or effects here
	queue_free() # Remove the graphics node when the logic node dies
