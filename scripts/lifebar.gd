extends ProgressBar

@export var length: int = 100
@export var width: int = 15

var current_health: int = 100
var max_health: int = 100

func _ready():
	size = Vector2(length,width)
	update_health_bar()

func update_health(new_health: int) -> void:
	current_health = clamp(new_health, 0, max_health)
	update_health_bar()

func update_health_bar() -> void:
	max_value = max_health
	value = current_health
	var health_ratio = float(current_health) / max_health
	var color = Color(1.0 - health_ratio, health_ratio, 0) # červená → zelená
	set_fill_color(color)

func set_fill_color(color: Color) -> void:
	var stylebox = get_theme_stylebox("fill", "ProgressBar")
	if stylebox == null or not stylebox is StyleBoxFlat:
		stylebox = StyleBoxFlat.new()
	else:
		stylebox = stylebox.duplicate()
	stylebox.bg_color = color
	add_theme_stylebox_override("fill", stylebox)
	
	# Některé verze Godotu vyžadují i nastavení "fg"
	var fg_stylebox = get_theme_stylebox("fg", "ProgressBar")
	if fg_stylebox == null or not fg_stylebox is StyleBoxFlat:
		fg_stylebox = StyleBoxFlat.new()
	else:
		fg_stylebox = fg_stylebox.duplicate()
	fg_stylebox.bg_color = color
	add_theme_stylebox_override("fg", fg_stylebox)

func set_max_health(value: int) -> void:
	max_health = value
	current_health = max_health
	update_health_bar()
