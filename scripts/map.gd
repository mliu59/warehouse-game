extends Node

@export var _map_width: int = 20
@export var _map_height: int = 20

@export var spawn_point: Vector2i = Vector2i(2, 2)


var astar = AStar2D.new()

func flatten_vector2i(v: Vector2i) -> int:
	return v.x * 1000 + v.y
func unflatten_vector2i(v: int) -> Vector2i:
	return Vector2i(v / 1000, v % 1000)


func clear_map() -> void:
	$ObjectManager.clear_objs()
	for child in get_children():
		if is_instance_of(child, TileMapLayer):
			child.clear()

func generate_map() -> void:
	clear_map()
	var _tiles: Array[Vector2i] = []
	for x in range(_map_width - 2):
		for y in range(_map_height - 2):
			var v = Vector2i(x+1, y+1)
			_tiles.append(v)
			astar.add_point(flatten_vector2i(v), v, 1.0)
	
	for id in astar.get_point_ids():
		var _point = unflatten_vector2i(id)
		for direction in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var _neighbour = _point + direction
			if astar.has_point(flatten_vector2i(_neighbour)):
				astar.connect_points(id, flatten_vector2i(_neighbour), 1.0)
		for direction in [Vector2i(1, 1), Vector2i(-1, -1), Vector2i(-1, 1), Vector2i(1, -1)]:
			var _neighbour = _point + direction
			if astar.has_point(flatten_vector2i(_neighbour)):
				astar.connect_points(id, flatten_vector2i(_neighbour), 1.414)
			
	var _walls: Array[Vector2i] = []
	for x in range(_map_width):
		_walls.append(Vector2i(x, 0))
		_walls.append(Vector2i(x, _map_height - 1))
	for y in range(_map_height):
		_walls.append(Vector2i(0, y))
		_walls.append(Vector2i(_map_width - 1, y))
	for wall in _walls:
		if astar.has_point(flatten_vector2i(wall)):
			astar.set_point_disabled(flatten_vector2i(wall))
	
	$Floor.set_cells_terrain_connect(_tiles, 0, 0, true)
	$Walls.set_cells_terrain_connect(_walls, 0, 0, true)

func get_astar(src: Vector2i, dest: Vector2i) -> Array[Vector2i]:
	var src_id = flatten_vector2i(src)
	var dest_id = flatten_vector2i(dest)
	var path = astar.get_id_path(src_id, dest_id)
	var output: Array[Vector2i] = []
	for p in path:
		output.append(unflatten_vector2i(p))
	return output

func get_world_pos(v: Vector2i) -> Vector2:
	return $Floor.map_to_local(v)

func remove_point_from_astar(v: Vector2i) -> void:
	astar.set_point_disabled(flatten_vector2i(v))

