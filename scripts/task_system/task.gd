class_name Task

extends Node

const subtask_ = preload("res://scripts/task_system/subtask.gd")

var subtasks_: Array = []
var subtasks_status_: Array[bool] = []
var current_task_index_: int = -1

func initialize_test_task(l1, l2, l3, l4) -> void:
	add_subtask(subtask_.SubtaskType.MOVE_TO, l1)
	add_subtask(subtask_.SubtaskType.INTERACT, l2)
	add_subtask(subtask_.SubtaskType.MOVE_TO, l3)
	add_subtask(subtask_.SubtaskType.INTERACT, l4)

func add_subtask(type, target) -> void:
	var subtask = subtask_.new()
	subtask.init(type, target)
	subtasks_.append(subtask)
	subtasks_status_.append(false)

func start_task() -> void:
	print("Task started")
	current_task_index_ = 0
	
func get_current_subtask() -> Subtask:
	print("Current subtask: ", current_task_index_)
	return subtasks_[current_task_index_]

# Returns true if there are more subtasks to execute
func next_subtask() -> bool:
	print("Next subtask, incrementing index")
	subtasks_status_[current_task_index_] = true
	current_task_index_ += 1
	return current_task_index_ < subtasks_.size()

