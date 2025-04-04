extends Node

@export var _map_width: int = 20
@export var _map_height: int = 20

@export var spawn_point: Vector2i = Vector2i(2, 2)


var astar = AStar2D.new()
var min_x = 999
var max_x = -999
var min_y = 999
var max_y = -999
var map_x_size_pixels: int = 0
var map_y_size_pixels: int = 0
var map_center_pixels: Vector2 = Vector2(0, 0)

func flatten_vector2i(v: Vector2i) -> int:
	return v.x * 1000 + v.y
func unflatten_vector2i(v: int) -> Vector2i:
	return Vector2i(v / 1000, v % 1000)


const adj_tile_directions: Array[TileSet.CellNeighbor] = [
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE
]

const diag_tile_directions: Array[TileSet.CellNeighbor] = [
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER
	
]

func clear_map() -> void:
	$ObjectManager.clear_objs()
	for child in get_children():
		if is_instance_of(child, TileMapLayer):
			child.clear()

func _update_map_lims(v: Vector2i) -> void:
	if v.x < min_x:
		min_x = v.x
	if v.x > max_x:
		max_x = v.x
	if v.y < min_y:
		min_y = v.y
	if v.y > max_y:
		max_y = v.y
func _calc_map_lims() -> void:
	var tile_size = $Floor.tile_set.tile_size
	var x = max_x - min_x + 1
	var y = max_y - min_y + 1
	map_x_size_pixels = (x+1) * tile_size.x
	map_y_size_pixels = (y+1) * tile_size.y
	var center_x = float(max_x + min_x) / 2
	var center_y = float(max_y + min_y) / 2
	var map_center_x = get_world_pos(Vector2i(0, 0)).x + (center_x * tile_size.x)
	var map_center_y = get_world_pos(Vector2i(0, 0)).y + (center_y * tile_size.y)
	map_center_pixels = Vector2(map_center_x, map_center_y)

func disable_diagonal_traversal(v: Vector2i):
	for i in range(4):
		var t1 = get_neighbor_cell(v, adj_tile_directions[i])
		var t2 = get_neighbor_cell(v, adj_tile_directions[(i+1)%4])
		if astar.has_point(flatten_vector2i(t1)) and astar.has_point(flatten_vector2i(t2)):
			astar.disconnect_points(flatten_vector2i(t1), flatten_vector2i(t2))

func generate_map() -> void:
	clear_map()
	var _tiles: Array[Vector2i] = []

	var clear_tiles = [
		Vector2i(1, 6), Vector2i(6, 2), Vector2i(5, 5)
	]

	# generate traversable map
	for x in range(_map_width):
		for y in range(_map_height):
			var v = Vector2i(x+1, y+1)
			if v in clear_tiles: continue
			_tiles.append(v)
			astar.add_point(flatten_vector2i(v), v, 1.0)
	
	# generate astar map
	for id in astar.get_point_ids():
		var _point = unflatten_vector2i(id)
		for direction in adj_tile_directions:
			var _neighbour = get_neighbor_cell(_point, direction)
			if astar.has_point(flatten_vector2i(_neighbour)):
				astar.connect_points(id, flatten_vector2i(_neighbour), 1.0)
		for direction in diag_tile_directions:
			var _neighbour = get_neighbor_cell(_point, direction)
			if astar.has_point(flatten_vector2i(_neighbour)):
				astar.connect_points(id, flatten_vector2i(_neighbour), 1.414)

	# generate walls: any tile adjacent to a map tile without itself being a map tile (borders of map)
	var _walls: Array[Vector2i] = []
	for tile in _tiles:
		for direction in adj_tile_directions + diag_tile_directions:
			var wall = get_neighbor_cell(tile, direction)
			if not astar.has_point(flatten_vector2i(wall)):
				_walls.append(wall)
				# do not allow diagonal traversal across walls
				disable_diagonal_traversal(wall)

	for tile in _tiles:
		_update_map_lims(tile)
	for wall in _walls:
		_update_map_lims(wall)
	_calc_map_lims()
	
	$Floor.set_cells_terrain_connect(_tiles, 0, 0, false)
	$Walls.set_cells_terrain_connect(_walls, 0, 0, false)

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

func get_neighbor_cell(coords: Vector2i, direction: TileSet.CellNeighbor) -> Vector2i:
	return $Floor.get_neighbor_cell(coords, direction)
