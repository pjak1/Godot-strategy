extends Node

class_name PathManager

var path_points: Array = []

func _ready():
	load_path_points()

func load_path_points():
	path_points.clear()
	for path in get_tree().get_nodes_in_group("Path"):
		if path is Path2D:
			var curve = path.curve
			var points: Array = []
			for i in range(curve.get_point_count()):
				points.append(path.to_global(curve.get_point_position(i)))
			path_points.append(points)

func is_near_path(pos: Vector2, radius: float) -> bool:
	for segment in path_points:
		for i in range(segment.size() - 1):
			var dist = _point_to_segment_distance(pos, segment[i], segment[i + 1])
			if dist < radius:
				return true
	return false

func _point_to_segment_distance(p: Vector2, a: Vector2, b: Vector2) -> float:
	var ab = b - a
	var t = clamp((p - a).dot(ab) / ab.length_squared(), 0.0, 1.0)
	var projection = a + t * ab
	return p.distance_to(projection)
