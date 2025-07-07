extends EntityGraphics

class_name TurretGraphics

# === Color Constants ===

# Semi-transparent white – used for preview when placement is valid
const COLOR_VALID_PREVIEW := Color(1, 1, 1, 0.5)

# Semi-transparent red – used for preview when placement is invalid
const COLOR_INVALID_PREVIEW := Color(1, 0.3, 0.3, 0.7)

# Fully opaque white – used after confirming turret placement
const COLOR_CONFIRMED := Color(1, 1, 1)

# Transparent red – used for debug drawing of turret range
const COLOR_DEBUG_RANGE := Color(1, 0, 0, 0.25)


# === Exported Variables ===
@export var rotation_speed: float = 5.0
@export var show_range_debug: bool = false

# === Onready Variables ===
@onready var turret_base: Node2D = $"." 
@onready var turret_barrel: Node2D = $Barrel

# === Runtime Variables ===
var target_angle: float = 0.0
var range_radius: float = 1000.0
var flash_sprites: Array[AnimatedSprite2D] = []

# === Lifecycle ===

func _ready() -> void:
	super._ready()
	life_bar_position = position + Vector2(-50, -90)
	setup_flash_sprites()
	connect_to_turret_logic()

func _process(delta: float) -> void:
	update_barrel_rotation(delta)
	queue_redraw()

func _draw() -> void:
	if show_range_debug:
		draw_debug_range()

# === Public Methods ===

func set_range_debug(enabled: bool) -> void:
	show_range_debug = enabled

func show_valid_preview() -> void:
	modulate = COLOR_VALID_PREVIEW
	set_range_debug(true)

func show_invalid_preview() -> void:
	modulate = COLOR_INVALID_PREVIEW

func confirm_placement() -> void:
	modulate = COLOR_CONFIRMED
	set_range_debug(false)

# === Private Methods ===

func setup_flash_sprites() -> void:
	for child in turret_barrel.get_children():
		if child is AnimatedSprite2D:
			var sprite := child as AnimatedSprite2D
			sprite.visible = false
			sprite.connect("animation_finished", func(): _on_flash_finished(sprite))
			flash_sprites.append(sprite)

func connect_to_turret_logic() -> void:
	var turret_logic = owner as TurretLogic

	if turret_logic:
		turret_logic.target_angle_changed.connect(_on_target_angle_changed)
		turret_logic.fire.connect(_on_fire)
		turret_logic.range_changed.connect(_on_range_changed)
		turret_logic.placement_state_changed.connect(_on_placement_state_changed)
	else:
		push_warning("TurretGraphics: Could not connect to TurretLogic")

func update_barrel_rotation(delta: float) -> void:
	turret_barrel.rotation = lerp_angle(turret_barrel.rotation, target_angle, rotation_speed * delta)

func draw_debug_range() -> void:
	draw_circle(turret_barrel.position, range_radius, COLOR_DEBUG_RANGE)

func notify_logic_about_barrel_rotation() -> void:
	var turret_logic = owner as TurretLogic
	if turret_logic:
		turret_logic.update_barrel_angle(turret_barrel.rotation)

func play_flash_effects() -> void:
	for flash in flash_sprites:
		flash.visible = true
		flash.frame = 0
		flash.play("shoot")

# === Signal Handlers ===

func _on_target_angle_changed(angle: float) -> void:
	target_angle = angle
	notify_logic_about_barrel_rotation()

func _on_fire(target_position: Vector2) -> void:
	play_flash_effects()

func _on_range_changed(new_range: float) -> void:
	range_radius = new_range

func _on_flash_finished(flash: AnimatedSprite2D) -> void:
	flash.visible = false

func _on_placement_state_changed(state: String) -> void:
	match state:
		"valid":
			show_valid_preview()
		"invalid":
			show_invalid_preview()
		"confirmed":
			confirm_placement()
