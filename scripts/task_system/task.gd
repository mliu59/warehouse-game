class_name Task

extends Node

const subtask_ = preload("res://scripts/task_system/subtask.gd")

var subtasks_: Array = []
var subtasks_status_: Array[bool] = []
var current_task_index_: int = -1

func initialize_test_task(src, tgt) -> void:
	add_subtask(subtask_.SubtaskType.MOVE_TO, src.get_tile_for_interaction(src.OBJ_INTERACTION_TYPE.RETRIEVE_ITEM))
	add_subtask(subtask_.SubtaskType.INTERACT, src, src.OBJ_INTERACTION_TYPE.RETRIEVE_ITEM)
	add_subtask(subtask_.SubtaskType.MOVE_TO, tgt.get_tile_for_interaction(src.OBJ_INTERACTION_TYPE.DEPOSIT_ITEM))
	add_subtask(subtask_.SubtaskType.INTERACT, tgt, tgt.OBJ_INTERACTION_TYPE.DEPOSIT_ITEM)

func add_subtask(type, target, interaction_type = -1) -> void:
	var subtask = subtask_.new()
	add_child(subtask)
	subtask.init(type, target, interaction_type)
	subtasks_.append(subtask)
	subtasks_status_.append(false)

func started() -> bool:
	return current_task_index_ != -1

func start_task() -> bool:
	if not started():
		print("Task started")
		current_task_index_ = 0
		return false
	return true
	
func get_current_subtask() -> Subtask:
	print("Current subtask: ", current_task_index_)
	return subtasks_[current_task_index_]

# Returns true if there are more subtasks to execute
func get_next_subtask() -> bool:
	print("Next subtask, incrementing index")
	subtasks_status_[current_task_index_] = true
	current_task_index_ += 1
	return current_task_index_ < subtasks_.size()

func finished() -> bool:
	return current_task_index_ >= subtasks_.size()

func has_next_subtask() -> bool:
	return current_task_index_ + 1 < subtasks_.size()
