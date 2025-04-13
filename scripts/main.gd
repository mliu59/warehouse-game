extends Node

const _worldObject = preload("res://scripts/world_objects/world_object.gd")

@export var test_source: Vector2i = Vector2i(2, 3)
@export var test_target: Vector2i = Vector2i(7, 7)
@export var spawn_point: Vector2i = Vector2i(1, 1)

func _ready() -> void:
	
	# generate map
	KeyNodes.map().generate_map()
	KeyNodes.camera().center_camera_for_map(KeyNodes.map())

	# generate static objs
	KeyNodes.objMgr().init_existing_objects()
	# KeyNodes.objMgr().clear_objs()
	# KeyNodes.objMgr().add_world_object("source_box", test_source)
	# KeyNodes.objMgr().add_world_object("target_box", test_target)
	# KeyNodes.objMgr().add_world_object("item_pile", Vector2i(4, 3))
	# KeyNodes.objMgr().add_world_object("item_pile", Vector2i(9, 2))
	# KeyNodes.objMgr().add_world_object("item_pile", Vector2i(16, 1))

	#populate inventories

	for id in ["source_box", "item_pile"]:
		var count = KeyNodes.objMgr().get_object_count(id)
		for i in range(count):
			var obj = KeyNodes.objMgr().get_object_by_index(id, i)
			if obj:
				obj.get_inventory().spawn_items("%TEST_ITEM%", 3)

	KeyNodes.agentMgr().start_tasks()
