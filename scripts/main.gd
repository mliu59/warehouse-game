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
	KeyNodes.objMgr().clear_objs()
	KeyNodes.objMgr().add_world_object("source_box", test_source)
	KeyNodes.objMgr().add_world_object("target_box", test_target)
	KeyNodes.objMgr().add_world_object("item_pile", Vector2i(4, 3))
	KeyNodes.objMgr().add_world_object("item_pile", Vector2i(9, 2))
	KeyNodes.objMgr().add_world_object("item_pile", Vector2i(16, 1))
	KeyNodes.objMgr().render_objects()

	#populate inventories
	KeyNodes.objMgr().get_object_by_index("source_box").get_inventory().spawn_items("%TEST_ITEM%", 1)
	KeyNodes.objMgr().get_object_by_index("item_pile", 0).get_inventory().spawn_items("%TEST_ITEM%", 2)
	KeyNodes.objMgr().get_object_by_index("item_pile", 1).get_inventory().spawn_items("%TEST_ITEM%", 2)
	KeyNodes.objMgr().get_object_by_index("item_pile", 2).get_inventory().spawn_items("%TEST_ITEM%", 2)

	KeyNodes.agentMgr().start_tasks()


