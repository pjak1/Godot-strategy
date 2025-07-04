extends Control
class_name EndGameMenu

# === Node References ===
@onready var button_restart: StyledButton = $VBoxContainer/Restart
@onready var button_quit: StyledButton = $VBoxContainer/Quit

# === Lifecycle ===

func _ready() -> void:
	# Connect button signals
	button_restart.pressed.connect(_on_restart_pressed)
	button_quit.pressed.connect(_on_quit_pressed)

# === Signal Handlers ===

# Restart the game by reloading the current scene
func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

# Quit the game/application
func _on_quit_pressed() -> void:
	get_tree().quit()
