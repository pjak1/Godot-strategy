extends Control

signal pressed(item_data)

@export var texture_normal: Texture2D
@export var texture_hover: Texture2D
@export var texture_pressed: Texture2D

var item_data: Variant
var hovered := false

@onready var button: TextureButton = $TextureButton

func _ready():
	if texture_normal:
		button.texture_normal = texture_normal
	if texture_hover:
		button.texture_hover = texture_hover
	if texture_pressed:
		button.texture_pressed = texture_pressed

	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL

	button.connect("pressed", _on_pressed)
	button.connect("mouse_entered", _on_mouse_entered)
	button.connect("mouse_exited", _on_mouse_exited)

	queue_redraw()

func _draw():
	var border_color = Color.YELLOW if hovered else Color(1, 1, 1)
	var border_width = 2.0

	var button_rect = Rect2(button.position, button.size)
	draw_rect(button_rect, border_color, false, border_width)

func _on_pressed():
	emit_signal("pressed", item_data)

func _on_mouse_entered():
	hovered = true
	queue_redraw()

func _on_mouse_exited():
	hovered = false
	queue_redraw()
