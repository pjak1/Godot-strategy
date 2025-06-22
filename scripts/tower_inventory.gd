extends Control

signal tower_selected(tower_scene: PackedScene)

@export var inventory_item_scene: PackedScene
@export var available_towers: Array[PackedScene] = []
@export var default_texture: Resource
@export var sprite_path: String

@onready var container := $GridContainer

func _ready():
	populate_inventory()

func populate_inventory():
	for tower_scene in available_towers:
		var item = inventory_item_scene.instantiate()
		
		var tower_instance = tower_scene.instantiate()
		
		var sprite_node = tower_instance.get_node(sprite_path)
		if sprite_node and sprite_node.texture:
			item.texture_normal = sprite_node.texture
		else:
			item.texture_normal = default_texture
		
		item.item_data = tower_scene
		item.connect("pressed", Callable(self, "_on_tower_selected"))
		
		container.add_child(item)

func _on_tower_selected(tower_scene: PackedScene):
	emit_signal("tower_selected", tower_scene)
