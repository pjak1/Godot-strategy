extends Node

class_name StatsDisplay

@export var stat_name : String

@onready var text : Label = $Text
@onready var value : Label = $Value

func _ready():
	set_text(stat_name)
	set_value(0)

func set_value(new_value: int):
	value.text = str(new_value)

func set_text(new_text: String):
	text.text = new_text
