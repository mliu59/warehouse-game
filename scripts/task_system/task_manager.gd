extends Node

var task_queue: Array = []

func get_global_task(_agent: Agent) -> Task:
	var task = Task.new()
	task.initialize_test_task()
	return task

func add_task_to_queue(_task: Task) -> void:
	task_queue.append(_task)
	add_child(_task)


func get_available_task(_agent: Agent) -> Task:
	if task_queue.size() == 0:
		add_task_to_queue(get_global_task(_agent))
	#check if agent can do task
	var top_task = task_queue.front()
	if top_task.if_agent_can_execute(_agent):
		if top_task.generate_work_order(_agent):
			return task_queue.pop_front()
	return null

func _ready() -> void:
	for i in range(2):
		var task = Task.new()
		task.initialize_drop_task()
		add_task_to_queue(task)
