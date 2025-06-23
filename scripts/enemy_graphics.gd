# EnemyGraphics.gd
extends EntityGraphics

class_name EnemyGraphics

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var enemy_logic: EnemyLogic = get_parent()

func _ready():
	super._ready()
	# Initialize sprite animation based on logic's type
	if enemy_logic.type:
		sprite.animation = enemy_logic.type
		sprite.frame = 0
		sprite.play()
	else:
		print("Animace '", enemy_logic.type, "' neexistuje!")
