extends Control

# === Exported Variables ===
@export var money_path: NodePath
@export var lives_path: NodePath
@export var wave_manager_path: NodePath
@export var end_game_menu_path: NodePath

# === Onready Variables ===
@onready var money_stat: StatsDisplay = $VBoxContainer/MoneyLeft
@onready var lives_stat: StatsDisplay = $VBoxContainer/LivesLeft

@onready var money = get_node(money_path)
@onready var lives = get_node(lives_path)
@onready var wave_manager = get_node(wave_manager_path)
@onready var end_game_menu = get_node(end_game_menu_path)

# === Runtime Variables ===
var is_last_wave: bool = false

# === Lifecycle ===
func _ready() -> void:
	wave_manager.all_waves_completed.connect(_on_last_wave)
	wave_manager.last_enemy_killed.connect(_on_last_enemy_killed)

# === Public Methods ===
func show_victory_screen() -> void:
	var current_money = money.get_current_money()
	var current_lives = lives.get_remaining_lives()
	
	money_stat.set_value(current_money)
	lives_stat.set_value(current_lives)

	show()

func victory() -> void:
	show_victory_screen()
	end_game_menu.show()
	get_tree().paused = true

# === Signal Handlers ===
func _on_last_enemy_killed() -> void:
	if is_last_wave:
		call_deferred("victory")

func _on_last_wave() -> void:
	is_last_wave = true
