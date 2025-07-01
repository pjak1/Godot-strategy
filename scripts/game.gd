extends Node2D

@onready var tower_inventory := $TowerInventory
@onready var money := $Money

@onready var placement := $TowerPlacementManager
@onready var enemies := $EnemyManager

func _ready():
	tower_inventory.connect("tower_selected", _on_tower_selected)
	enemies.connect("enemy_killed", _on_enemy_killed)

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
