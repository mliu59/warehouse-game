extends Node

@export var _use_scene: bool = true
@export var _map_width: int = 20
@export var _map_height: int = 20


var astar: TileMapAStar = TileMapAStar.new()
var min_x = 999
var max_x = -999
var min_y = 999
var max_y = -999
var map_x_size_pixels: int = 0
var map_y_size_pixels: int = 0
var map_center_pixels: Vector2 = Vector2(0, 0)

func get_carpet_floor():					return $Floor
func get_walls():							return $Walls
func get_debug_grid():						return $Debug/Grid
func get_debug_grid_labels():				return $Debug/GridLabels

func clear_map() -> void:
	# KeyNodes.objMgr().clear_objs()
	for child in get_children():
		if is_instance_of(child, TileMapLayer):
			child.clear()

func _update_map_lims(v: Vector2i) -> void:
	if v.x < min_x:	min_x = v.x
	if v.x > max_x:	max_x = v.x
	if v.y < min_y:	min_y = v.y
	if v.y > max_y:	max_y = v.y
func _calc_map_lims() -> void:
	var tile_size = get_carpet_floor().tile_set.tile_size
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
		var t1 = get_neighbor_cell(v, MapUtils.ADJ_TILES[i])
		var t2 = get_neighbor_cell(v, MapUtils.ADJ_TILES[(i+1)%4])
		astar.disconnect_pts(t1, t2)

func generate_map_tiles() -> Array[Vector2i]:
	var _tiles: Array[Vector2i] = []
	var clear_tiles = [Vector2i(1, 6), Vector2i(6, 2), Vector2i(5, 5)]
	for x in range(_map_width):
		for y in range(_map_height):
			var v = Vector2i(x+1, y+1)
			if v in clear_tiles: continue
			_tiles.append(v)
	return _tiles

func generate_map() -> void:
	var _tiles: Array[Vector2i] = []

	if not _use_scene:
		_tiles = generate_map_tiles()
	else:
		var walls = get_walls().get_used_cells()
		for tile in get_carpet_floor().get_used_cells():
			if tile.x < 1 or tile.y < 1: continue
			if tile in walls: continue
			_tiles.append(tile)
	clear_map()
	
	for tile in _tiles: 	astar.add_pt(tile)
	# generate astar map
	for tile in _tiles:		astar.connect_pt_to_all_neighbors(tile, get_carpet_floor())

	# generate walls: any tile adjacent to a map tile without itself being a map tile (borders of map)
	var _walls: Array[Vector2i] = []
	for tile in _tiles:
		var potential_walls = MapUtils.get_neighbors(tile, MapUtils.ADJ_TILES_8, get_carpet_floor())
		for wall in potential_walls:
			if not astar.pt_open(wall):
				_walls.append(wall)
				disable_tile(wall) # do not allow diagonal traversal across walls

	for tile in _tiles:		_update_map_lims(tile)
	for wall in _walls:		_update_map_lims(wall)
	_calc_map_lims()
	
	get_carpet_floor().set_cells_terrain_connect(_tiles, 0, 0, false)
	get_walls().set_cells_terrain_connect(_walls, 0, 0, false)

	populate_debug_grid()

func get_tile_path(src: Vector2i, dest: Vector2i) -> Array[Vector2i]:
	return astar.get_path(src, dest)
func get_distance(src: Vector2i, dest: Vector2i) -> float:
	return astar.get_distance(src, dest)

func get_world_pos(v: Vector2i) -> Vector2:
	return get_carpet_floor().map_to_local(v)

func disable_tile(v: Vector2i) -> void:
	astar.remove_pt(v)
	disable_diagonal_traversal(v)
func enable_tile(v: Vector2i) -> void:
	astar.enable_pt(v)

func get_neighbor_cell(coords: Vector2i, direction: TileSet.CellNeighbor) -> Vector2i:
	return get_carpet_floor().get_neighbor_cell(coords, direction)

func get_random_open_tile() -> Vector2i:
	var rng = RandomNumberGenerator.new()
	var tile = null
	while tile == null or not astar.pt_open(tile):
		tile = Vector2i(rng.randi_range(min_x, max_x), rng.randi_range(min_y, max_y))
	return tile

func get_virtual_tiles_by_distance(center: Vector2i, distance: int) -> Array:
	var tiles = []
	for x in range(center.x - distance, center.x + distance + 1):
		for y in range(center.y - distance, center.y + distance + 1):
			var v = Vector2i(x, y)
			# if astar.pt_open(v) and get_distance(center, v) == distance:
			tiles.append(v)
	return tiles


func populate_debug_grid() -> void:
	get_debug_grid().clear()
	for i in range(max_x - min_x + 3):
		for j in range(max_y - min_y + 3):
			var x = i+min_x-1
			var y = j+min_y-1
			var v = Vector2i(x, y)
			get_debug_grid().set_cell(v, 0, Vector2i(0, 0))
			var tag = Label.new()
			tag.text = str(x) + "," + str(y)
			tag.position = get_carpet_floor().map_to_local(v) + Vector2(-5, -5)
			tag.modulate = Color(0, 0, 0, 1)
			tag.add_theme_font_size_override("font_size", 5)
			get_debug_grid_labels().add_child(tag)


func get_tiles_for_interaction(search_params: Dictionary, interaction_params: Dictionary, agent: Agent) -> Array:
	var outputs = []
	if interaction_params["type"] == ObjInteractionConsts.TYPE.DROP_ITEM:
		if search_params.has("tgt_tile") and astar.pt_open(search_params["tgt_tile"]) and \
			KeyNodes.map().get_distance(search_params["tgt_tile"], agent.get_tile()) > 0:

			outputs.append(search_params["tgt_tile"])
		else:
			var pot_tiles = get_virtual_tiles_by_distance(agent.get_tile(), 10)
			for tile in pot_tiles:
				if astar.pt_open(tile) and KeyNodes.map().get_distance(tile, agent.get_tile()) > 0:
					outputs.append(tile)
					if search_params.has("any") and search_params["any"]: break
		
	return outputs
