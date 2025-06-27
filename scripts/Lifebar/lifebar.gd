extends ProgressBar

@export var length: int = 100
@export var width: int = 15
@export var max_health: int = 100

var current_health: int

func _ready() -> void:
	current_health = max_health
	# Set the size of the ProgressBar control
	size = Vector2(length, width)
	# Initialize the visual state of the health bar
	update_health_bar()

func update_health(new_health: int) -> void:
	# Clamp new health between 0 and max_health to avoid invalid values
	current_health = clamp(new_health, 0, max_health)
	# Update the visual representation accordingly
	update_health_bar()

func update_health_bar() -> void:
	# Update the max_value and current value of the ProgressBar
	max_value = max_health
	value = current_health
	
	# Calculate the health ratio (0.0 to 1.0)
	var health_ratio = float(current_health) / max_health
	
	# Create a color gradient from red (low health) to green (high health)
	var color = Color(1.0 - health_ratio, health_ratio, 0)
	
	# Apply the color to the fill part of the progress bar
	set_fill_color(color)

func set_fill_color(color: Color) -> void:
	# Get the "fill" style box from the current theme
	var stylebox = get_theme_stylebox("fill", "ProgressBar")
	
	# If not found or not the right type, create a new flat stylebox
	if stylebox == null or not stylebox is StyleBoxFlat:
		stylebox = StyleBoxFlat.new()
	else:
		# Otherwise, duplicate it so we don't modify the original theme style directly
		stylebox = stylebox.duplicate()
	
	# Set the background color to the desired fill color
	stylebox.bg_color = color
	
	# Override the theme stylebox for the fill part with our customized one
	add_theme_stylebox_override("fill", stylebox)
	
	# Do the same for the "fg" (foreground) stylebox for consistency
	var fg_stylebox = get_theme_stylebox("fg", "ProgressBar")
	
	if fg_stylebox == null or not fg_stylebox is StyleBoxFlat:
		fg_stylebox = StyleBoxFlat.new()
	else:
		fg_stylebox = fg_stylebox.duplicate()
		
	fg_stylebox.bg_color = color
	add_theme_stylebox_override("fg", fg_stylebox)

func set_max_health(value: int) -> void:
	# Set maximum health and reset current health to max
	max_health = value
	current_health = max_health
	
	# Update the visual bar to reflect the new health max
	update_health_bar()
