extends Node

const _worldObject = preload("res://scripts/world_objects/world_object.gd")
var obj_map: Dictionary = {}
var obj_type_map: Dictionary = {}



func add_object(obj: WorldObject, type: String) -> void:
	add_child(obj)
	obj_map[obj.get_tile()] = obj
	if obj_type_map.has(type):
		obj_type_map[type][obj.get_tile()] = obj
	else:
		obj_type_map[type] = {obj.get_tile(): obj}
	if not obj.passable_:
		get_node("/root/Main").get_map().remove_point_from_astar(obj.get_tile())

func get_object(tile: Vector2i) -> WorldObject:
	return obj_map.get(tile, null)

func get_first_object(type: String) -> WorldObject:
	if obj_type_map.has(type):
		return obj_type_map[type].values().front()
	return null

func clear_objs() -> void:
	obj_map.clear()
	obj_type_map.clear()

# PLACEHOLDER FUNCTIONS
func set_test_source(test_source, test_source_sprite):
	var sourceObj = _worldObject.new()
	sourceObj.atlas_pos_ = test_source_sprite
	sourceObj.pos_ = test_source
	add_object(sourceObj, "Source")

func set_test_target(test_target, test_target_sprite):
	var targetObj = _worldObject.new()
	targetObj.atlas_pos_ = test_target_sprite
	targetObj.pos_ = test_target
	add_object(targetObj, "Target")


func render_objects() -> void:
	for obj in obj_map.values():
		obj.render()

