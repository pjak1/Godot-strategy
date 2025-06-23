extends Node2D

class_name EntityGraphics
@export var life_bar_position: Vector2 = Vector2(-50, -80)

@onready var entity_logic: Entity = get_parent()

var LifeBarScene = preload("res://scenes//lifebar.tscn")
var life_bar: ProgressBar = null

func _ready():
	entity_logic.health_updated.connect(update_life_bar)
	entity_logic.died.connect(on_entity_died)
	_setup_life_bar(life_bar_position)

func update_life_bar(new_health: int, max_health: int):
	if life_bar:
		life_bar.update_health(new_health)

func on_entity_died():
	# Handle any death animations or effects here
	queue_free() # Remove the graphics node when the logic node dies

func _setup_life_bar(position: Vector2):
	var life_bar_instance = LifeBarScene.instantiate()
	add_child(life_bar_instance)
	life_bar_instance.position = position
	life_bar_instance.set_max_health(entity_logic.max_health)
	life_bar_instance.update_health(entity_logic.current_health)
	life_bar = life_bar_instance
