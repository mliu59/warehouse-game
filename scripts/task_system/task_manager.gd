extends Node

var task_queue: Array = []

func get_global_task(_agent: Agent) -> Task:
	var task = Task.new()
	task.initialize_test_task()
	return task


func get_available_task(_agent: Agent) -> Task:
	if task_queue.size() == 0:
		var task = get_global_task(_agent)
		task_queue.append(task)
		add_child(task)
	#check if agent can do task
	var top_task = task_queue.front()
	if top_task.if_agent_can_execute(_agent):
		if top_task.generate_work_order(_agent):
			return task_queue.pop_front()
	return null
