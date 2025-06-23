extends Control

signal pressed(item_data)

@export var texture_normal: Texture2D
@export var texture_hover: Texture2D
@export var texture_pressed: Texture2D
@export var minimal_item_size : Vector2 = Vector2(64, 64)

var item_data: Variant
var hovered := false

@onready var button: TextureButton = $TextureButton

func _ready():
	_initialize_size()
	_apply_textures()
	_configure_button()
	_connect_signals()
	queue_redraw()

func _initialize_size() -> void:
	custom_minimum_size = minimal_item_size
	button.size = minimal_item_size

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
	button.connect("pressed", _on_pressed)
	button.connect("mouse_entered", _on_mouse_entered)
	button.connect("mouse_exited", _on_mouse_exited)

func _draw():
	var border_color = Color.YELLOW if hovered else Color(1, 1, 1)
	var border_width = 2.0
	
	# Use fixed size defined by minimal_item_size for border
	var border_rect = Rect2(Vector2.ZERO, minimal_item_size)
	
	draw_rect(border_rect, border_color, false, border_width)

func _on_pressed():
	emit_signal("pressed", item_data)

func _on_mouse_entered():
	hovered = true
	queue_redraw()

func _on_mouse_exited():
	hovered = false
	queue_redraw()
