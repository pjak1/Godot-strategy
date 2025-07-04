extends Node2D
class_name EntityGraphics

# === Exported Variables ===
@export var life_bar_position: Vector2 = position + Vector2(-50, -80)

# === Node References ===
@onready var entity_logic: Entity = get_parent()

# === Internal Resources ===
var LifeBarScene: PackedScene = preload("res://scenes/lifebar.tscn")
var life_bar: ProgressBar = null

# === Lifecycle ===

func _ready() -> void:
	entity_logic.health_updated.connect(update_life_bar)
	entity_logic.died.connect(on_entity_died)
	_setup_life_bar(life_bar_position)

# === Signal Handlers ===

# Updates the life bar when health changes
func update_life_bar(new_health: int, max_health: int) -> void:
	if life_bar:
		if not life_bar.visible:
			life_bar.visible = true

		life_bar.update_health(new_health)

# Removes this graphics node when the entity dies
func on_entity_died(entity: Entity, attacker: Entity) -> void:
	queue_free()

# === Public Methods ===

# Retrieves the first texture found in a Sprite2D or AnimatedSprite2D
func get_inventory_sprite_texture() -> Texture2D:
	return _find_first_sprite_with_texture(self)

# === Private Methods ===

# Creates and sets up the life bar UI element
func _setup_life_bar(position: Vector2) -> void:
	var life_bar_instance: ProgressBar = LifeBarScene.instantiate()
	life_bar_instance.position = position
	life_bar_instance.set_max_health(entity_logic.max_health)
	life_bar_instance.update_health(entity_logic.current_health)
	life_bar_instance.visible = false

	life_bar = life_bar_instance
	add_child(life_bar_instance)

# Recursively searches for the first sprite node that has a texture
func _find_first_sprite_with_texture(node: Node) -> Texture2D:
	for child in node.get_children():
		if child is Sprite2D or child is AnimatedSprite2D:
			if child.texture:
				return child.texture

		if child.get_child_count() > 0:
			var texture: Texture2D = _find_first_sprite_with_texture(child)
			if texture:
				return texture

	return null
