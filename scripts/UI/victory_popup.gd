extends Control

@export var money_node: NodePath
@export var lives_node: NodePath

@onready var money_label: Label = $MoneyLabel
@onready var lives_label: Label = $LivesLabel
@onready var money = get_node(money_node)
@onready var lives = get_node(lives_node)

func _ready():
	hide()  # skryté do konce hry

func show_victory_screen():
	var current_money = money.get_current_money()
	var current_lives = lives.get_remaining_lives()

	money_label.text = "Zbývající peníze: %d" % current_money
	lives_label.text = "Zbývající životy: %d" % current_lives

	show()
