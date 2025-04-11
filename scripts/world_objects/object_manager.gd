extends Node

const _worldObject = preload("res://scripts/world_objects/world_object.gd")

const WORLD_OBJECTS = [
	"res://scenes/world_objects/source_box.tscn",
	"res://scenes/world_objects/target_box.tscn",
	"res://scenes/world_objects/item_pile.tscn",
]

var world_object_dict: Dictionary = {}
func _init() -> void:
	for world_object in WORLD_OBJECTS:
		var obj = load(world_object).instantiate()
		world_object_dict[obj.get_u_name()] = world_object
		obj.queue_free()

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
	obj.set_u_id(running_id_counter)
	running_id_counter += 1

func get_object_count(type: String) -> int:
	if obj_type_map.has(type):
		return obj_type_map[type].size()
	return 0
func get_object_by_index(type: String, index: int = 0) -> WorldObject:
	if obj_type_map.has(type):
		var obj_list = obj_type_map[type]
		if index >= 0 and index < obj_list.size():
			return obj_list.values()[index]
	return null

func remove_world_object(obj: WorldObject) -> void:
	if obj_map.has(obj.get_tile()):
		obj_map.erase(obj.get_tile())
		if obj_type_map.has(obj.get_u_name()):
			obj_type_map[obj.get_u_name()].erase(obj.get_tile())
		obj.queue_free()
		KeyNodes.map().enable_tile(obj.get_tile())
	else:
		print("Object not found in map")

func clear_objs() -> void:
	obj_map.clear()
	obj_type_map.clear()
	for child in get_children():
		if is_instance_of(child, WorldObject):
			remove_child(child)

func add_world_object(type: String, tile: Vector2i) -> WorldObject:
	if world_object_dict.has(type):
		var obj = load(world_object_dict[type]).instantiate()
		obj.set_tile(tile)
		add_object(obj, type)
		return obj
	else:
		print("Object type not found in dictionary")
		return null


func render_objects() -> void:
	for obj in obj_map.values():
		obj.render()
