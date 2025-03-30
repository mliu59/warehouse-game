extends Node

const task_ = preload("res://scripts/task_system/task.gd")

var task_queue: Array = []

func map():
	return get_node("/root/Main").get_map()
func objMgr():
	return get_node("/root/Main").get_object_manager()

func get_global_task() -> Task:

	# TEST TASK
	var src = objMgr().get_first_object("Source")
	var tgt = objMgr().get_first_object("Target")
	var task = task_.new()
	task.initialize_test_task(src, tgt)
	return task

func get_task() -> Task:
	if task_queue.size() == 0:
		var task = get_global_task()
		task_queue.append(task)
		add_child(task)
	return task_queue.pop_front()
