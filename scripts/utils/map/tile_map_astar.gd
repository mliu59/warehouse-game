extends AStar2D
class_name TileMapAStar

func flatten_vector2i(v: Vector2i) -> int:
	return v.x * 1000 + v.y
func unflatten_vector2i(v: int) -> Vector2i:
	return Vector2i(v / 1000, v % 1000)

func get_path(start: Vector2i, end: Vector2i) -> Array[Vector2i]:
	# Returns a path from start to end using A* algorithm.
	# The path is a list of Vector2i points.
	# If no path is found, returns an empty array.
	var path = get_point_path(flatten_vector2i(start), flatten_vector2i(end))
	var path_tiles:Array[Vector2i] = []
	for i in range(path.size()):
		path_tiles.append(Vector2i(path[i]))
	return path_tiles

func _has_v(v: Vector2i) -> bool:
	return has_point(flatten_vector2i(v))

func get_distance(start: Vector2i, end: Vector2i) -> int:
	# Returns the distance between two points using A* algorithm.
	# If no path is found, returns -1.
	if not _has_v(start) or not _has_v(end):
		return -1
	var path = get_point_path(flatten_vector2i(start), flatten_vector2i(end))
	if path.size() == 0:
		return -1
	return path.size()

func remove_pt(v: Vector2i) -> bool:
	# Removes a point from the A* algorithm.
	# Returns true if the point was removed, false if it was not found.
	if _has_v(v):
		set_point_disabled(flatten_vector2i(v), true)
		return true
	return false


func enable_pt(v: Vector2i) -> bool:
	# Enables a point in the A* algorithm.
	# Returns true if the point was enabled, false if it was not found.
	if _has_v(v):
		set_point_disabled(flatten_vector2i(v), false)
		return true
	return false


func add_pt(v: Vector2i, cost: float = 1.0) -> bool:
	# Adds a point to the A* algorithm.
	# Returns true if the point was added, false if it was already present.
	if not _has_v(v):
		add_point(flatten_vector2i(v), v, cost)
		return true
	return false

func connect_pt_to_all_neighbors(v: Vector2i, tml: TileMapLayer) -> void:
	# Connects a point to all its neighbors in the A* algorithm.
	if not _has_v(v):
		return
	var neighbors = MapUtils.get_neighbors(v, MapUtils.ADJ_TILES_8, tml)
	for n in neighbors:
		if _has_v(n):
			connect_points(flatten_vector2i(v), flatten_vector2i(n))


func disconnect_pts(v1: Vector2i, v2: Vector2i) -> void:
	# Disconnects two points in the A* algorithm.
	if _has_v(v1) and _has_v(v2):
		disconnect_points(flatten_vector2i(v1), flatten_vector2i(v2))

func pt_open(v: Vector2i) -> bool:
	# Returns true if the point is open in the A* algorithm.
	if _has_v(v):
		return is_point_disabled(flatten_vector2i(v)) == false
	return false
