extends EntityGraphics

class_name TurretGraphics

@onready var turret_base: Node2D = $"." 
@onready var turret_barrel: Node2D = $Barrel
@onready var turret_logic: TurretLogic = get_parent()

@export var rotation_speed: float = 5.0
@export var angle_offset_deg: float = 87.0
@export var show_range_debug: bool = false

# Automatically collected flash sprite nodes
var flash_sprites: Array[AnimatedSprite2D] = []
func _ready():
	life_bar_position = position + Vector2(-50,-90)
	super._ready()
	# Find all AnimatedSprite2D children in Barrel
	for child in turret_barrel.get_children():
		if child is AnimatedSprite2D:
			var sprite := child as AnimatedSprite2D
			sprite.visible = false
			sprite.connect("animation_finished", func(): _on_flash_finished(sprite))
			flash_sprites.append(sprite)

	if turret_logic and turret_logic is TurretLogic:
		turret_logic.target_angle_changed.connect(_on_target_angle_changed)
		turret_logic.delt_damage.connect(_on_shot)
	else:
		push_error("TurretGraphics: Parent is not TurretLogic or is null!")

func _process(delta):
	queue_redraw()

func _on_target_angle_changed(new_angle: float):
	if turret_barrel:
		turret_barrel.rotation = lerp_angle(turret_barrel.rotation, new_angle, rotation_speed * get_process_delta_time())

func _on_shot(target_position: Vector2):
	for flash in flash_sprites:
		flash.visible = true
		flash.frame = 0
		flash.play("shoot")

func _on_flash_finished(flash_to_hide: AnimatedSprite2D):
	flash_to_hide.visible = false

func _draw():
	if show_range_debug and turret_barrel and turret_logic and turret_logic is TurretLogic:
		var range = turret_logic.range
		draw_circle(turret_barrel.position, range, Color(1, 0, 0, 0.25))
