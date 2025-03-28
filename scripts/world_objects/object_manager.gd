extends Node

const _worldObject = preload("res://scripts/world_objects/world_object.gd")
var obj_map: Dictionary = {}
var obj_type_map: Dictionary = {}

func map():
	return get_tree().get_nodes_in_group("map")[0]


func add_object(obj: WorldObject, type: String) -> void:
	add_child(obj)
	obj_map[obj.get_tile()] = obj
	if obj_type_map.has(type):
		obj_type_map[type][obj.get_tile()] = obj
	else:
		obj_type_map[type] = {obj.get_tile(): obj}
	if not obj.passable_:
		map().remove_point_from_astar(obj.get_tile())
	$Objects.set_cell(obj.get_tile(), 0, obj.atlas_pos_)

func get_object(tile: Vector2i) -> WorldObject:
	return obj_map.get(tile, null)

func get_first_object(type: String) -> WorldObject:
	if obj_type_map.has(type):
		return obj_type_map[type].values().front()
	return null

func clear_objs() -> void:
	obj_map.clear()
	obj_type_map.clear()
	$Objects.clear()
