extends Node2D

# === Onready Variables ===
@onready var tower_inventory := $TowerInventory
@onready var money := $Money
@onready var placement := $TowerPlacementManager
@onready var enemies := $EnemyManager
@onready var player_health := $PlayerHealth
@onready var game_over_menu := $EndGameMenu

# === Signals ===
signal reward_given

# === Lifecycle ===
func _ready() -> void:
	tower_inventory.connect("tower_selected", _on_tower_selected)
	enemies.connect("enemy_killed", _on_enemy_killed)
	player_health.game_over.connect(_on_gameover)

# === Input Handling ===
func _input(event) -> void:
	if not placement.is_placing() or placement.tower_to_place == null or not placement.ready_for_confirm:
		return

	if event is InputEventMouseMotion:
		placement.update_position(get_global_mouse_position())
	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			placement.confirm(get_global_mouse_position())
		elif event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
			placement.cancel()

# === Signal Handlers ===
func _on_tower_selected(scene: PackedScene) -> void:
	if not placement.is_now_placing:
		placement.start_placing(scene)

func _on_enemy_killed(enemy: EnemyLogic, attacker: Entity) -> void:
	if attacker:
		money.add_money(enemy.reward)

func _on_gameover() -> void:
	game_over_menu.visible = true
	get_tree().paused = true
