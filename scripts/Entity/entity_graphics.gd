extends Node2D

class_name EntityGraphics

@export var life_bar_position: Vector2 = position + Vector2(-50, -80)

@onready var entity_logic: Entity = get_parent()

var LifeBarScene = preload("res://scenes//lifebar.tscn")
var life_bar: ProgressBar = null

func _ready():
	entity_logic.health_updated.connect(update_life_bar)
	entity_logic.died.connect(on_entity_died)
	_setup_life_bar(life_bar_position)

func update_life_bar(new_health: int, max_health: int):
	if life_bar:
		if not life_bar.visible:
			life_bar.visible = true
			
		life_bar.update_health(new_health)

func on_entity_died():
	queue_free() # Remove the graphics node when the logic node dies

func _setup_life_bar(position: Vector2):
	var life_bar_instance = LifeBarScene.instantiate()
	
	life_bar_instance.position = position
	life_bar_instance.set_max_health(entity_logic.max_health)
	life_bar_instance.update_health(entity_logic.current_health)
	life_bar_instance.visible = false
	life_bar = life_bar_instance
	
	add_child(life_bar_instance)

func get_inventory_sprite_texture() -> Texture2D:
	return _find_first_sprite_with_texture(self)

func _find_first_sprite_with_texture(node: Node) -> Texture2D:
	for child in node.get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			if child.texture:
				return child.texture
		
		if child.get_child_count() > 0:
			var texture = _find_first_sprite_with_texture(child)
			if texture:
				return texture
	
	return null
