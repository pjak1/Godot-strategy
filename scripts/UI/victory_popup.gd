extends Control

@export var money_path: NodePath
@export var lives_path: NodePath
@export var wave_manager_path: NodePath
@export var end_game_menu_path: NodePath

@onready var money_stat: StatsDisplay = $VBoxContainer/MoneyLeft
@onready var lives_stat: StatsDisplay = $VBoxContainer/LivesLeft

@onready var money = get_node(money_path)
@onready var lives = get_node(lives_path)
@onready var wave_manager = get_node(wave_manager_path)
@onready var end_game_menu = get_node(end_game_menu_path)

var is_last_wave: bool = false

func _ready():
	wave_manager.all_waves_completed.connect(_on_last_wave)
	wave_manager.last_enemy_killed.connect(_on_last_enemy_killed)

func show_victory_screen():
	var current_money = money.get_current_money()
	var current_lives = lives.get_remaining_lives()
	
	money_stat.set_value(current_money)
	lives_stat.set_value(current_lives)

	show()

func victory():
	show_victory_screen()
	end_game_menu.show()
	
	get_tree().paused = true

func _on_last_enemy_killed():
	if is_last_wave:
		call_deferred("victory")

func _on_last_wave():
	is_last_wave = true
