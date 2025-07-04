extends ProgressBar

# === Exported Variables ===
@export var length: int = 100
@export var width: int = 15
@export var max_health: int = 100

# === Runtime Variables ===
var current_health: int

# === Lifecycle ===

func _ready() -> void:
	current_health = max_health
	size = Vector2(length, width)
	_update_health_bar()

# === Public Methods ===

# Sets the current health value and updates the bar
func update_health(new_health: int) -> void:
	current_health = clamp(new_health, 0, max_health)
	_update_health_bar()

# Sets the maximum health and resets current value
func set_max_health(value: int) -> void:
	max_health = value
	current_health = max_health
	_update_health_bar()

# === Private Methods ===

# Updates progress bar value and color based on current health
func _update_health_bar() -> void:
	max_value = max_health
	value = current_health

	var health_ratio: float = float(current_health) / max_health
	var fill_color: Color = Color(1.0 - health_ratio, health_ratio, 0.0)

	_set_fill_color(fill_color)

# Applies a given color to the fill and foreground of the progress bar
func _set_fill_color(color: Color) -> void:
	var stylebox: StyleBox = get_theme_stylebox("fill", "ProgressBar")
	if stylebox == null or not stylebox is StyleBoxFlat:
		stylebox = StyleBoxFlat.new()
	else:
		stylebox = stylebox.duplicate()

	stylebox.bg_color = color
	add_theme_stylebox_override("fill", stylebox)

	var fg_stylebox: StyleBox = get_theme_stylebox("fg", "ProgressBar")
	if fg_stylebox == null or not fg_stylebox is StyleBoxFlat:
		fg_stylebox = StyleBoxFlat.new()
	else:
		fg_stylebox = fg_stylebox.duplicate()

	fg_stylebox.bg_color = color
	add_theme_stylebox_override("fg", fg_stylebox)
