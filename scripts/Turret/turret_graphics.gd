extends EntityGraphics

class_name TurretGraphics

@export var rotation_speed: float = 5.0
@export var show_range_debug: bool = false

@onready var turret_base: Node2D = $"." 
@onready var turret_barrel: Node2D = $Barrel

var target_angle: float = 0.0
var range_radius: float = 1000.0
var flash_sprites: Array[AnimatedSprite2D] = []

func _ready():
	super._ready()
	life_bar_position = position + Vector2(-50, -90)
	setup_flash_sprites()
	connect_to_turret_logic()

func _process(delta):
	update_barrel_rotation(delta)
	queue_redraw()

func set_range_debug(enabled: bool):
	show_range_debug = enabled

func _draw():
	if show_range_debug:
		draw_debug_range()

func setup_flash_sprites():
	for child in turret_barrel.get_children():
		if child is AnimatedSprite2D:
			var sprite := child as AnimatedSprite2D
			sprite.visible = false
			sprite.connect("animation_finished", func(): _on_flash_finished(sprite))
			flash_sprites.append(sprite)

func connect_to_turret_logic():
	var turret_logic = owner as TurretLogic
	
	if turret_logic:
		turret_logic.target_angle_changed.connect(_on_target_angle_changed)
		turret_logic.fire.connect(_on_fire)
		turret_logic.range_changed.connect(_on_range_changed)
		turret_logic.placement_state_changed.connect(_on_placement_state_changed)
	else:
		push_warning("TurretGraphics: Could not connect to TurretLogic")

func update_barrel_rotation(delta: float):
	turret_barrel.rotation = lerp_angle(turret_barrel.rotation, target_angle, rotation_speed * delta)

func draw_debug_range():
	draw_circle(turret_barrel.position, range_radius, Color(1, 0, 0, 0.25))

func _on_target_angle_changed(angle: float):
	target_angle = angle
	notify_logic_about_barrel_rotation()

func _on_fire(target_position: Vector2):
	play_flash_effects()

func _on_range_changed(new_range: float):
	range_radius = new_range

func notify_logic_about_barrel_rotation():
	var turret_logic = owner as TurretLogic
	if turret_logic:
		turret_logic.update_barrel_angle(turret_barrel.rotation)

func play_flash_effects():
	for flash in flash_sprites:
		flash.visible = true
		flash.frame = 0
		flash.play("shoot")

func show_valid_preview():
	modulate = Color(1, 1, 1, 0.5)
	set_range_debug(true)

func show_invalid_preview():
	modulate = Color(1, 0.3, 0.3, 0.7)

func confirm_placement():
	modulate = Color(1, 1, 1)
	set_range_debug(false)

func _on_flash_finished(flash: AnimatedSprite2D):
	flash.visible = false

func _on_placement_state_changed(state: String):
	match state:
		"valid":
			show_valid_preview()
		"invalid":
			show_invalid_preview()
		"confirmed":
			confirm_placement()
