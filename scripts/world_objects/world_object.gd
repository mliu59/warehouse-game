extends Sprite2D
class_name WorldObject

var atlas_: TileSet = preload("res://scenes/tileset/furniture.tres")

var atlas_pos_: Vector2i = Vector2i(6, 2)
var interact_directions_: Array = []
var pos_: Vector2i = Vector2i(0, 0)

var interactable_: bool = false
var passable_: bool = false
var size_: Vector2i = Vector2i(1, 1)
var visible_: bool = true

func get_cell_texture() -> Texture:
	var source:TileSetAtlasSource = atlas_.get_source(0) as TileSetAtlasSource
	var rect := source.get_tile_texture_region(atlas_pos_)
	var image:Image = source.texture.get_image()
	var tile_image := image.get_region(rect)
	return ImageTexture.create_from_image(tile_image)

func render() -> void:
	set_texture(get_cell_texture())
	position = get_node("/root/Main").get_map().get_world_pos(get_tile())

func get_tile() -> Vector2i:
	return pos_
