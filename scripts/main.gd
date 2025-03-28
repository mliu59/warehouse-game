extends Node

const _worldObject = preload("res://scripts/world_objects/world_object.gd")


@export var test_source: Vector2i = Vector2i(3, 3)
@export var test_target: Vector2i = Vector2i(16, 16)
@export var test_source_sprite = Vector2i(7, 1)
@export var test_target_sprite = Vector2i(0, 2)

func _ready() -> void:
	
	$Map.generate_map()

	var sourceObj = _worldObject.new()
	sourceObj.atlas_pos_ = test_source_sprite
	sourceObj.pos_ = test_source
	$Map/ObjectManager.add_object(sourceObj, "Source")

	var targetObj = _worldObject.new()
	targetObj.atlas_pos_ = test_target_sprite
	targetObj.pos_ = test_target
	$Map/ObjectManager.add_object(targetObj, "Target")

	for i in range(1):
		var agent = load("res://scenes/elf.tscn").instantiate()
		$AgentManager.add_child(agent)
		agent.start_tasks()

