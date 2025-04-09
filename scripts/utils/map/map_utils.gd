extends Node

const ADJ_TILES: Array[TileSet.CellNeighbor] = [
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE
]

const DIAG_TILES: Array[TileSet.CellNeighbor] = [
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER
]

const ADJ_TILES_8: Array[TileSet.CellNeighbor] = [
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_LEFT_CORNER,
	TileSet.CellNeighbor.CELL_NEIGHBOR_BOTTOM_RIGHT_CORNER,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_RIGHT_CORNER,
	TileSet.CellNeighbor.CELL_NEIGHBOR_TOP_LEFT_CORNER
]

func get_neighbors(v: Vector2i, dirs: Array[TileSet.CellNeighbor], tml: TileMapLayer) -> Array[Vector2i]:
	# Returns the neighbors of a given point in the specified directions.
	var neighbors: Array[Vector2i] = []
	for dir in dirs:
		var neighbor = tml.get_neighbor_cell(v, dir)
		neighbors.append(neighbor)
	return neighbors
