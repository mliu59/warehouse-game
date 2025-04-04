extends Node

const _worldObject = preload("res://scripts/world_objects/world_object.gd")

var obj_map: Dictionary = {}
var obj_type_map: Dictionary = {}
var running_id_counter: int = 0

func add_object(obj: WorldObject, type: String) -> void:
	add_child(obj)
	obj_map[obj.get_tile()] = obj
	if obj_type_map.has(type):
		obj_type_map[type][obj.get_tile()] = obj
	else:
		obj_type_map[type] = {obj.get_tile(): obj}
	obj.init()

	obj._id = running_id_counter
	running_id_counter += 1

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
	var sourceObj = load("res://scenes/world_object.tscn").instantiate()
	sourceObj.atlas_pos_ = test_source_sprite
	sourceObj.pos_ = test_source
	sourceObj._name = "Source"
	sourceObj.interactable_ = true
	add_object(sourceObj, "Source")
	for i in range(3):
		var item = load("res://scenes/generic_item.tscn").instantiate()
		sourceObj.get_inventory().add_item(item)

func set_test_target(test_target, test_target_sprite):
	var targetObj = load("res://scenes/world_object.tscn").instantiate()
	targetObj.atlas_pos_ = test_target_sprite
	targetObj.pos_ = test_target
	targetObj._name = "Target"
	targetObj.interactable_ = true
	add_object(targetObj, "Target")


func render_objects() -> void:
	for obj in obj_map.values():
		obj.render()
