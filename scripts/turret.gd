extends Area2D

@export var rotation_speed = 5.0
@export var rate_of_fire = 1.0  # výstřely za sekundu
@onready var turret = $Turret
@onready var turret_barrel = $Barrel
@export var angle_offset_deg = 87
@onready var flash: AnimatedSprite2D = $Barrel/Flash
@onready var flash2: AnimatedSprite2D = $Barrel/Flash2

var fire_cooldown = 0.0

func _ready():
	flash.visible = false
	flash2.visible = false
		
	flash.connect("animation_finished", func():
		_on_flash_finished(flash)
	)
	flash2.connect("animation_finished", func():
		_on_flash_finished(flash2)
	)

func _process(delta):
	fire_cooldown = max(fire_cooldown - delta, 0.0)
	
	var target = find_nearest_enemy()
	if target:
		var direction = target.global_position - turret_barrel.global_position
		var target_angle = direction.angle() + deg_to_rad(angle_offset_deg)
		turret_barrel.rotation = lerp_angle(turret_barrel.rotation, target_angle, rotation_speed * delta)

		var angle_diff = abs(angle_wrap(turret_barrel.rotation - target_angle))
		var fire_threshold = 0.05  # menší = přesnější natočení

		if angle_diff < fire_threshold and fire_cooldown <= 0.0:
			shoot()
			fire_cooldown = 1.0 / rate_of_fire  # nastav cooldown podle rof

func find_nearest_enemy() -> Node2D:
	var nearest_enemy = null
	var shortest_distance = INF

	for enemy in get_tree().get_nodes_in_group("Enemy"):
		if enemy and enemy is Node2D:
			var distance = global_position.distance_to(enemy.global_position)
			if distance < shortest_distance:
				shortest_distance = distance
				nearest_enemy = enemy

	return nearest_enemy

func shoot():
	# tvůj kód pro vystřelení střely
	# ...

	# efekt výstřelu
	flash.visible = true
	flash2.visible = true
	flash.frame = 0
	flash2.frame = 0
	flash.play("shoot")
	flash2.play("shoot")


func angle_wrap(angle):
	while angle > PI:
		angle -= TAU
	while angle < -PI:
		angle += TAU
	return angle
	
func _on_flash_finished(flash_to_hide: AnimatedSprite2D):
	flash_to_hide.visible = false
