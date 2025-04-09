extends Node

const _worldObject = preload("res://scripts/world_objects/world_object.gd")

@export var test_source: Vector2i = Vector2i(3, 3)
@export var test_target: Vector2i = Vector2i(7, 7)
@export var spawn_point: Vector2i = Vector2i(1, 1)

func _ready() -> void:
	
	# generate map
	get_map().generate_map()
	get_camera().center_camera_for_map(get_map())

	# generate static objs
	get_object_manager().clear_objs()
	get_object_manager().add_world_object("source_box", test_source)
	get_object_manager().add_world_object("target_box", test_target)
	get_object_manager().add_world_object("item_pile", Vector2i(5, 3))
	get_object_manager().add_world_object("item_pile", Vector2i(9, 2))
	get_object_manager().render_objects()

	#populate inventories
	for i in range(3):
		var item = load("res://scenes/generic_item.tscn").instantiate()
		get_object_manager().get_object_by_index("source_box").get_inventory().add_item(item)
	for i in range(3):
		var item = load("res://scenes/generic_item.tscn").instantiate()
		get_object_manager().get_object_by_index("item_pile", 0).get_inventory().add_item(item)
	for i in range(3):
		var item = load("res://scenes/generic_item.tscn").instantiate()
		get_object_manager().get_object_by_index("item_pile", 1).get_inventory().add_item(item)

	# generate agents
	for i in range(1):
		var agent = get_agent_manager().add_agent("elf", spawn_point)
		agent.start_tasks()

## easy access functions for high level managing nodes
func get_map() -> Node:
	return $Map
func get_agent_manager() -> Node:
	return $AgentManager
func get_object_manager() -> Node:
	return $Map/ObjectManager
func get_task_manager() -> Node:
	return $TaskManager
func get_camera() -> Node:
	return $MainCamera2D
