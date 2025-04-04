extends Node

const _worldObject = preload("res://scripts/world_objects/world_object.gd")


@export var test_source: Vector2i = Vector2i(3, 3)
@export var test_target: Vector2i = Vector2i(7, 7)
@export var test_source_sprite = Vector2i(7, 1)
@export var test_target_sprite = Vector2i(0, 2)

func _ready() -> void:
	
	# generate map
	get_map().generate_map()
	get_camera().center_camera_for_map(get_map())

	# generate static objs
	get_object_manager().clear_objs()
	get_object_manager().set_test_source(test_source, test_source_sprite)
	get_object_manager().set_test_target(test_target, test_target_sprite)
	get_object_manager().render_objects()

	# generate agents
	for i in range(1):
		var agent = load("res://scenes/elf.tscn").instantiate()
		get_agent_manager().add_child(agent)
		agent.start_tasks()

	

## easy access functions for high level managing nodes
func get_map() -> Node:
	return $Map

func get_agent_manager() -> Node:
	return $AgentManager

func get_object_manager() -> Node:
	# print("get_object_manager")
	return $Map/ObjectManager

func get_task_manager() -> Node:
	return $TaskManager
func get_camera() -> Node:
	return $MainCamera2D
