extends Control
class_name TowerInventory

# === Exported Variables ===
@export var inventory_item_scene: PackedScene
@export var available_towers: Array[PackedScene] = []
@export var number_of_columns: int = 4

# === Node References ===
@onready var container: GridContainer = $VBoxContainer/GridContainer
@onready var toggle_button: Button = $VBoxContainer/Button

# === Runtime Variables ===
var inventory_visible: bool = true

# === Signals ===
signal tower_selected(tower_scene: PackedScene)

# === Lifecycle ===

func _ready() -> void:
	_setup_container()
	_setup_toggle_button()
	_create_inventory_items()

# === Signal Handlers ===

func _on_toggle_button_pressed() -> void:
	_toggle_inventory_visibility()

func _on_tower_selected(tower_scene: PackedScene) -> void:
	emit_signal("tower_selected", tower_scene)

# === Private Methods ===

# Configure container layout
func _setup_container() -> void:
	container.columns = number_of_columns

# Connect button signal
func _setup_toggle_button() -> void:
	toggle_button.pressed.connect(_on_toggle_button_pressed)

# Instantiate and add all available tower items
func _create_inventory_items() -> void:
	for tower_scene in available_towers:
		var item_button: Control = _create_inventory_item(tower_scene)
		container.add_child(item_button)

# Instantiate one inventory item from a tower scene
func _create_inventory_item(tower_scene: PackedScene) -> Control:
	var item: Control = inventory_item_scene.instantiate()
	var tower_instance: Node = tower_scene.instantiate()

	item.texture_normal = _get_inventory_texture_from_entity(tower_instance)
	item.item_data = tower_scene
	item.cost = tower_instance.cost
	item.pressed.connect(_on_tower_selected)

	return item

# Attempts to extract an inventory texture from an entity
func _get_inventory_texture_from_entity(entity: Node) -> Texture2D:
	for child in entity.get_children():
		if child.has_method("get_inventory_sprite_texture"):
			return child.get_inventory_sprite_texture()
	return null

# Show or hide the inventory container
func _toggle_inventory_visibility() -> void:
	inventory_visible = !inventory_visible
	container.visible = inventory_visible
	toggle_button.text = "Hide Inventory" if inventory_visible else "Show Inventory"
