extends Node2D

@onready var tower_inventory := $TowerInventory
@onready var money := $Money

@onready var placement := $TowerPlacementManager
@onready var enemies := $EnemyManager
@onready var player_health := $PlayerHealth
@onready var game_over_menu := $EndGameMenu

func _ready():
	tower_inventory.connect("tower_selected", _on_tower_selected)
	enemies.connect("enemy_killed", _on_enemy_killed)
	player_health.game_over.connect(_on_gameover)

func _input(event):
	if not placement.is_placing():
		return

	if event is InputEventMouseMotion:
		placement.update_position(get_global_mouse_position())
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			placement.confirm(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			placement.cancel()

func _on_tower_selected(scene: PackedScene):
	placement.start_placing(scene)

func _on_enemy_killed(enemy: EnemyLogic, attacker:Entity):
	if attacker:
		money.add_money(enemy.reward)

func _on_gameover():
	game_over_menu.visible = true
	get_tree().paused = true
