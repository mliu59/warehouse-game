extends Node2D
class_name GenericItem

@export var item_id: String = "%TEST_ITEM%"

var reserved: bool = false
var _task: Task = null

func get_item_id() -> String:
	return item_id

func is_reserved() -> bool:
	return reserved
func set_reserved(_reserved: bool, task: Task) -> void:
	reserved = _reserved
	if reserved: _task = task
	else: _task = null
func get_reserved_task() -> Task:
	return _task
