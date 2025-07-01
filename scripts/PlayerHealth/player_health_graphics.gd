extends Node

class_name PlayerHealthGraphics

@onready var player_health_logic: PlayerHealthLogic = owner
@onready var label: Label = $Label 

var current_lives: int = 0

func _ready():
	player_health_logic.lives_changed.connect(_on_lives_changed)

func update_lives(new_value: int):
	label.text = str(new_value)

func _on_lives_changed(current: int, max: int):
	current_lives = current
	update_lives(current)
