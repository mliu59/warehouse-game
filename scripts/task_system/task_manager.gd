extends Node

const task_ = preload("res://scripts/task_system/task.gd")

var task_queue: Array = []

func map():
	return get_node("/root/Main").get_map()
func objMgr():
	return get_node("/root/Main").get_object_manager()

func get_global_task() -> Task:

	# TEST TASK
	var src = objMgr().get_first_object("Source").get_tile()
	var tgt = objMgr().get_first_object("Target").get_tile()
	var l1 = src + Vector2i(-1, 0)
	var l2 = src
	var l3 = tgt + Vector2i(-1, 0)
	var l4 = tgt
	var task = task_.new()
	task.initialize_test_task(l1, l2, l3, l4)
	return task

func get_task() -> Task:
	if task_queue.size() == 0:
		return get_global_task()
	return task_queue.pop_front()



