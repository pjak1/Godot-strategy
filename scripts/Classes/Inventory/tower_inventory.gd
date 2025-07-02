extends Control

class_name TowerInventory

@export var inventory_item_scene: PackedScene
@export var available_towers: Array[PackedScene] = []
@export var number_of_columns = 4

@onready var container := $VBoxContainer/GridContainer
@onready var toggle_button := $VBoxContainer/Button

var inventory_visible := true

signal tower_selected(tower_scene: PackedScene)

func _ready():
	setup_container()
	setup_toggle_button()
	create_inventory_items()

func setup_container():
	container.columns = number_of_columns

func setup_toggle_button():
	toggle_button.connect("pressed", _on_toggle_button_pressed)
	
func create_inventory_items():
	for tower_scene in available_towers:
		var item_button = create_inventory_item(tower_scene)
		container.add_child(item_button)

func create_inventory_item(tower_scene: PackedScene) -> Control:
	var item = inventory_item_scene.instantiate()
	var tower_instance = tower_scene.instantiate()
	
	item.texture_normal = get_inventory_texture_from_entity(tower_instance)
	item.item_data = tower_scene
	item.cost = tower_instance.cost
	item.connect("pressed", Callable(self, "_on_tower_selected"))
	
	return item

func get_inventory_texture_from_entity(entity: Node) -> Texture2D:
	for child in entity.get_children():
		if child.has_method("get_inventory_sprite_texture"):
			return child.get_inventory_sprite_texture()
	return null

func toggle_inventory_visibility():
	inventory_visible = !inventory_visible
	container.visible = inventory_visible
	toggle_button.text = "Hide Inventory" if inventory_visible else "Show Inventory"

func _on_tower_selected(tower_scene: PackedScene):
	emit_signal("tower_selected", tower_scene)

func _on_toggle_button_pressed():
	toggle_inventory_visibility()
