extends Control
class_name Money

# === Onready Variables ===
@onready var label: Label = $Label
@onready var money_icon: TextureRect = $MoneyIcon

@onready var money_logic: MoneyLogic = get_parent()

# === Lifecycle ===

func _ready() -> void:
	money_logic.money_changed.connect(_on_money_changed)
	_on_money_changed(money_logic.money_amount)

# === Public Methods ===

func set_money(new_amount: int) -> void:
	label.text = str(new_amount)

# === Signal Handlers ===

func _on_money_changed(new_amount: int) -> void:
	set_money(new_amount)
