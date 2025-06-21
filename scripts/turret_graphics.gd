extends Node2D

class_name TurretGraphics

@onready var turret_base: Node2D = $"."
@onready var turret_barrel: Node2D = $Barrel
@onready var flash: AnimatedSprite2D = $Barrel/Flash
@onready var flash2: AnimatedSprite2D = $Barrel/Flash2

@onready var turret_logic: TurretLogic = get_parent()

@export var rotation_speed: float = 5.0
@export var angle_offset_deg: float = 87.0
@export var show_range_debug: bool = true

func _ready():
	flash.visible = false
	flash2.visible = false
		
	if turret_logic and turret_logic is TurretLogic:
		turret_logic.target_angle_changed.connect(_on_target_angle_changed)
		turret_logic.shot.connect(_on_shot)
	else:
		push_error("TurretGraphics: Rodič není TurretLogic nebo je null!")

	flash.connect("animation_finished", func(): _on_flash_finished(flash))
	flash2.connect("animation_finished", func(): _on_flash_finished(flash2))

func _process(delta):
	queue_redraw()

func _on_target_angle_changed(new_angle: float):
	if turret_barrel:
		turret_barrel.rotation = lerp_angle(turret_barrel.rotation, new_angle, rotation_speed * get_process_delta_time())

func _on_shot(target_position: Vector2):
	flash.visible = true
	flash2.visible = true
	flash.frame = 0
	flash2.frame = 0
	flash.play("shoot")
	flash2.play("shoot")

func _on_flash_finished(flash_to_hide: AnimatedSprite2D):
	flash_to_hide.visible = false

func _draw():
	if show_range_debug and turret_barrel and turret_logic and turret_logic is TurretLogic:
		var range = turret_logic.range
		draw_circle(turret_barrel.position, range, Color(1, 0, 0, 0.25))
