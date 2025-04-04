extends Node2D
class_name WorldObject

var atlas_: TileSet = preload("res://scenes/tileset/furniture.tres")
var atlas_source_: TileSetAtlasSource = atlas_.get_source(0) as TileSetAtlasSource

enum OBJ_INTERACTION_TYPE {
	USE,
	EXAMINE,
	RETRIEVE_ITEM,
	DEPOSIT_ITEM
}

var allowed_interaction_types_: Array = [
	OBJ_INTERACTION_TYPE.RETRIEVE_ITEM,
	OBJ_INTERACTION_TYPE.DEPOSIT_ITEM
]

var interaction_directions_: Dictionary = {
	OBJ_INTERACTION_TYPE.RETRIEVE_ITEM: [
		TileSet.CellNeighbor.CELL_NEIGHBOR_RIGHT_SIDE
	],
	OBJ_INTERACTION_TYPE.DEPOSIT_ITEM: [
		TileSet.CellNeighbor.CELL_NEIGHBOR_LEFT_SIDE
	]
}

var interaction_times_: Dictionary = {
	OBJ_INTERACTION_TYPE.RETRIEVE_ITEM: 500,
	OBJ_INTERACTION_TYPE.DEPOSIT_ITEM: 500
}

var atlas_pos_: Vector2i = Vector2i(6, 2)
var pos_: Vector2i = Vector2i(0, 0)
var _id: int = 0
var _name: String = "WorldObject"

var interactable_: bool = false
var passable_: bool = false
var size_: Vector2i = Vector2i(1, 1)
var visible_: bool = true

func map():
	return get_node("/root/Main").get_map()

func init() -> void:
	if not passable_:
		map().remove_point_from_astar(get_tile())

func get_cell_texture() -> Texture:
	var rect := atlas_source_.get_tile_texture_region(atlas_pos_)
	var image:Image = atlas_source_.texture.get_image()
	var tile_image := image.get_region(rect)
	return ImageTexture.create_from_image(tile_image)

func render() -> void:
	$sprite.set_texture(get_cell_texture())
	position = map().get_world_pos(get_tile())

func get_tile() -> Vector2i:
	return pos_

func get_obj_id() -> int:
	return _id

func get_obj_name() -> String:
	return _name

func get_tile_for_interaction(interaction_type) -> Vector2i:
	return map().get_neighbor_cell(get_tile(), interaction_directions_[interaction_type][0])

func get_time_for_interaction(interaction_type) -> int:
	return interaction_times_[interaction_type]

func interact(agent: Agent, interaction_type) -> bool:
	if not interactable_:
		print("Object is not interactable")
		return false
	if not allowed_interaction_types_.has(interaction_type):
		print("Interaction type not allowed")
		return false
	
	var source = null
	var target = null
	if interaction_type == OBJ_INTERACTION_TYPE.RETRIEVE_ITEM:
		print("Retrieving item from ", get_obj_name())
		source = get_inventory()
		target = agent.get_inventory()
	elif interaction_type == OBJ_INTERACTION_TYPE.DEPOSIT_ITEM:
		print("Depositing item to ", get_obj_name())
		source = agent.get_inventory()
		target = get_inventory()
	else:
		print("Unknown interaction type")
		return false
	
	return source.transfer_item_to(target, "%TEST_ITEM%", 1)

func get_inventory():
	return $GenericInventory

func get_inventory_counter():
	return $TEST_ITEM_COUNTER
func _on_inventory_changed():
	get_inventory_counter().set_text(str(get_inventory().get_inventory_size()))
