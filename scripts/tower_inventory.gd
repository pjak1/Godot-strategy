extends Control

signal tower_selected(tower_scene: PackedScene)

@export var inventory_item_scene: PackedScene
@export var available_towers: Array[PackedScene] = []
@export var default_texture: Resource
@export var sprite_path: String
@export var number_of_items = 4

@onready var container := $VBoxContainer/GridContainer
@onready var toggle_button := $VBoxContainer/Button

var inventory_visible := true

func _ready():
	container.columns = number_of_items
	toggle_button.text = "Hide Inventory"
	toggle_button.connect("pressed", _on_toggle_button_pressed)
	populate_inventory()

func populate_inventory():
	for tower_scene in available_towers:
		var item = inventory_item_scene.instantiate()
		var tower_instance = tower_scene.instantiate()
		var texture_to_use = default_texture
		var sprite_node = tower_instance.get_node_or_null(sprite_path)
		
		if sprite_node:
			for child in sprite_node.get_children():
				if child is Sprite2D or child is AnimatedSprite2D:
					if child.texture:
						texture_to_use = child.texture
						break

		item.texture_normal = texture_to_use
		item.item_data = tower_scene
		item.connect("pressed", Callable(self, "_on_tower_selected"))
		container.add_child(item)

func _on_tower_selected(tower_scene: PackedScene):
	emit_signal("tower_selected", tower_scene)
	
func _on_toggle_button_pressed():
	inventory_visible = !inventory_visible
	container.visible = inventory_visible
	toggle_button.text = "Hide Inventory" if inventory_visible else "Show Inventory"
