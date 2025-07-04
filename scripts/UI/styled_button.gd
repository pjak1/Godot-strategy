extends Button

class_name StyledButton

# === Exported Variables ===
@export var default_color: Color = Color(0.2, 0.2, 0.2)
@export var hover_color: Color = Color(0.4, 0.4, 0.4)
@export var corner_radius: int = 12
@export var margin_left: int = 8
@export var margin_right: int = 8
@export var margin_top: int = 4
@export var margin_bottom: int = 4

# === Lifecycle ===
func _ready() -> void:
	apply_style(default_color)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# === Signal Handlers ===
func _on_mouse_entered() -> void:
	apply_style(hover_color)

func _on_mouse_exited() -> void:
	apply_style(default_color)

# === Private Methods ===
func apply_style(color: Color) -> void:
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
