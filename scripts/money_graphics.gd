extends Control
class_name Money

@onready var label: Label = $Label
@onready var money_icon: TextureRect = $MoneyIcon

@onready var money_logic: MoneyLogic = get_parent()

func _ready() -> void:
	money_logic.money_changed.connect(_on_money_changed)
	_on_money_changed(money_logic.money_amount)

func _on_money_changed(new_amount: int) -> void:
	label.text = str(new_amount)
