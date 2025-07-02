extends Button

class_name StyledButton

@export var default_color: Color = Color(0.2, 0.2, 0.2)
@export var hover_color: Color = Color(0.4, 0.4, 0.4)
@export var corner_radius: int = 12
@export var margin_left := 8
@export var margin_right := 8
@export var margin_top := 4
@export var margin_bottom := 4

func _ready():
	apply_style(default_color)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered():
	apply_style(hover_color)

func _on_mouse_exited():
	apply_style(default_color)

func apply_style(color: Color):
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = color

	stylebox.content_margin_left = margin_left
	stylebox.content_margin_right = margin_right
	stylebox.content_margin_top = margin_top
	stylebox.content_margin_bottom = margin_bottom

	stylebox.set_corner_radius(CORNER_TOP_LEFT, corner_radius)
	stylebox.set_corner_radius(CORNER_TOP_RIGHT, corner_radius)
	stylebox.set_corner_radius(CORNER_BOTTOM_LEFT, corner_radius)
	stylebox.set_corner_radius(CORNER_BOTTOM_RIGHT, corner_radius)

	for state in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(state, stylebox)
