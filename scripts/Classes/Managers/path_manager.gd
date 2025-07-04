extends Node
class_name PathManager

var path_points: Array = []

# Called when the node enters the scene tree for the first time
func _ready() -> void:
	load_path_points()

# Loads points from all Path2D nodes in "Path" group
func load_path_points() -> void:
	path_points.clear()
	for path in get_tree().get_nodes_in_group("Path"):
		if path is Path2D:
			var curve = path.curve
			var points: Array = []
			for i in range(curve.get_point_count()):
				points.append(path.to_global(curve.get_point_position(i)))
			path_points.append(points)

# Checks if the given position is within radius of any path segment
func is_near_path(pos: Vector2, radius: float) -> bool:
	for segment in path_points:
		for i in range(segment.size() - 1):
			var dist: float = _point_to_segment_distance(pos, segment[i], segment[i + 1])
			if dist < radius:
				return true
	return false

# Calculates shortest distance from point p to line segment ab
func _point_to_segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var t = clamp((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
	var projection = a + t * ab
	return p.distance_to(projection)
