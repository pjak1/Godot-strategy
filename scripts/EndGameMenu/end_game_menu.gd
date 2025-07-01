extends Control

@onready var button_restart: Button = $VBoxContainer/Restart
@onready var button_quit: Button = $VBoxContainer/Quit

# Barvy
var default_color = Color(0.2, 0.2, 0.2)
var hover_color = Color(0.4, 0.4, 0.4)

func _ready():
	# Nastavení barev na začátku
	_set_button_style(button_restart)
	_set_button_style(button_quit)

	# Připojení signálů
	button_restart.mouse_entered.connect(func(): _on_button_hover(button_restart, true))
	button_restart.mouse_exited.connect(func(): _on_button_hover(button_restart, false))
	button_restart.pressed.connect(_on_restart_pressed)

	button_quit.mouse_entered.connect(func(): _on_button_hover(button_quit, true))
	button_quit.mouse_exited.connect(func(): _on_button_hover(button_quit, false))
	button_quit.pressed.connect(_on_quit_pressed)

func _set_button_style(button: Button):
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = default_color
	button.add_theme_stylebox_override("normal", stylebox)

func _on_button_hover(button: Button, hovering: bool):
	var stylebox : StyleBoxFlat = button.get_theme_stylebox("normal").duplicate()
	stylebox.bg_color = hover_color if hovering else default_color
	button.add_theme_stylebox_override("normal", stylebox)

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
