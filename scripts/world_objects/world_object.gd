extends UniqueActor
class_name WorldObject

var atlas_: TileSet = preload("res://scenes/tileset/furniture.tres")
var atlas_source_: TileSetAtlasSource = atlas_.get_source(0) as TileSetAtlasSource
var atlas_pos_: Vector2i = Vector2i(6, 2)

func get_cell_texture() -> Texture:
	var rect := atlas_source_.get_tile_texture_region(atlas_pos_)
	var image:Image = atlas_source_.texture.get_image()
	var tile_image := image.get_region(rect)
	return ImageTexture.create_from_image(tile_image)


var allowed_interaction_types_: Array = [
	ObjInteractionConsts.TYPE.RETRIEVE_ITEM,
	ObjInteractionConsts.TYPE.DEPOSIT_ITEM
]

var interaction_directions_: Dictionary = {
	ObjInteractionConsts.TYPE.RETRIEVE_ITEM: MapUtils.ADJ_TILES_8,
	ObjInteractionConsts.TYPE.DEPOSIT_ITEM: MapUtils.ADJ_TILES_8
}

var interaction_times_: Dictionary = {
	ObjInteractionConsts.TYPE.RETRIEVE_ITEM: 500,
	ObjInteractionConsts.TYPE.DEPOSIT_ITEM: 500
}

var interactable_: bool = false
var passable_: bool = false
var size_: Vector2i = Vector2i(1, 1)
var visible_: bool = true
var hide_inventory_: bool = false
var destroy_on_empty_inventory_: bool = false

func _init() -> void:
	init_unique_actor()
	_config_object()
	
func config_object() -> void: pass # Override this function in subclasses to configure the object

func _config_object() -> void:
	config_object()
	get_inventory().inventory_changed.connect(_on_inventory_changed)

	var sprite_obj = Sprite2D.new()
	sprite_obj.set_texture(get_cell_texture())
	add_child(sprite_obj)

func init() -> void:
	if not passable_: KeyNodes.map().disable_tile(get_tile())

func get_closest_interaction_tile(src: Vector2i, interaction_type) -> Vector2i:
	var closest = null
	var closest_dist = 9999999
	for tile in get_tiles_for_interaction(interaction_type):
		var dist = KeyNodes.map().get_distance(src, tile)
		if dist > -1 and dist < closest_dist:
			closest = tile
			closest_dist = dist
	return closest


func render() -> void:
	position = KeyNodes.map().get_world_pos(get_tile())
	get_inventory().visible = not hide_inventory_

func allows_interaction(interaction_type) -> bool:
	return allowed_interaction_types_.has(interaction_type)

func get_tiles_for_interaction(interaction_type) -> Array:
	return MapUtils.get_neighbors(
		get_tile(), interaction_directions_[interaction_type], KeyNodes.map().get_carpet_floor())

func get_time_for_interaction(interaction_type) -> int:
	return interaction_times_[interaction_type]

func _destroy() -> void:
	id_print("Destroying object")
	KeyNodes.objMgr().remove_world_object(self)

func _on_inventory_changed():
	# get_inventory_counter().set_text(str(get_inventory().get_inventory_size()))
	if get_inventory().is_empty() and destroy_on_empty_inventory_:
		_destroy()
