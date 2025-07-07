extends Node
class_name BoundsValidator

# === Exported Variables ===
@export var tilemap: TileMapLayer
@export var margin_left: int = 100
@export var margin_right: int = 100
@export var margin_top: int = 0
@export var margin_bottom: int = 0

# === Public Methods ===

# Returns true if the given position is outside the calculated bounds
func is_out_of_bounds(pos: Vector2) -> bool:
	return not _get_bounds_rect().has_point(pos)

# === Private Methods ===

# Calculates the rectangular playable area based on tilemap and margins
func _get_bounds_rect() -> Rect2:
	var used_rect: Rect2 = tilemap.get_used_rect()
	var top_left: Vector2 = tilemap.map_to_local(used_rect.position)
	var bottom_right: Vector2 = tilemap.map_to_local(used_rect.position + used_rect.size)
	
	var bounds_rect: Rect2 = Rect2(top_left, bottom_right - top_left)

	bounds_rect.position.x += margin_left
	bounds_rect.position.y += margin_top
	bounds_rect.size.x -= (margin_left + margin_right)
	bounds_rect.size.y -= (margin_top + margin_bottom)

	return bounds_rect
