extends Control

class_name EndGameMenu

@onready var button_restart: StyledButton = $VBoxContainer/Restart
@onready var button_quit: StyledButton = $VBoxContainer/Quit

func _ready():
	button_restart.pressed.connect(_on_restart_pressed)
	button_quit.pressed.connect(_on_quit_pressed)

func _on_restart_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_pressed():
	get_tree().quit()
