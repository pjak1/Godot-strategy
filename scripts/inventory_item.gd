extends Control

signal pressed(item_data)

@export var texture_normal: Texture2D
@export var texture_hover: Texture2D
@export var texture_pressed: Texture2D
@export var minimal_item_size: Vector2 = Vector2(64, 64)

@onready var button: TextureButton = $TextureButton
@onready var money: HBoxContainer = $MoneyGraphics

var item_data: Variant
var hovered := false
var cached_bounds: Rect2 = Rect2(Vector2.ZERO, minimal_item_size)

func _ready():
	_initialize_layout()
	_apply_textures()
	_configure_button()
	_connect_signals()
	queue_redraw()

func _initialize_layout() -> void:
	custom_minimum_size = minimal_item_size
	size = minimal_item_size
	button.size = minimal_item_size
	money.position = Vector2(10, 70)
	money.z_index = 1

func _apply_textures() -> void:
	if texture_normal:
		button.texture_normal = texture_normal
	if texture_hover:
		button.texture_hover = texture_hover
	if texture_pressed:
		button.texture_pressed = texture_pressed

func _configure_button() -> void:
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL

func _connect_signals() -> void:
	button.pressed.connect(_on_pressed)
	button.mouse_entered.connect(_on_mouse_entered)
	button.mouse_exited.connect(_on_mouse_exited)

func _on_pressed():
	emit_signal("pressed", item_data)

func _on_mouse_entered():
	hovered = true
	queue_redraw()

func _on_mouse_exited():
	hovered = false
	queue_redraw()
