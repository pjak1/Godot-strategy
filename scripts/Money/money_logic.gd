extends Node

class_name MoneyLogic

@export var money_amount: int = 100

signal money_changed(new_amount: int)

func add_money(amount: int) -> void:
	money_amount += amount
	emit_signal("money_changed", money_amount)

func spend_money(amount: int) -> bool:
	if money_amount >= amount:
		money_amount -= amount
		emit_signal("money_changed", money_amount)
		return true
	else:
		return false

func get_current_money():
	return money_amount
