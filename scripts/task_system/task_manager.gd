extends Node

const task_ = preload("res://scripts/task_system/task.gd")

var task_queue: Array = []

func find_world_object(objects: Array, criteria_func: Callable, _agent: Agent, _closest: bool = true) -> WorldObject:
	var outputs = []
	for obj_name in objects:
		var obj_count = KeyNodes.objMgr().get_object_count(obj_name)
		for i in range(obj_count):
			var obj = KeyNodes.objMgr().get_object_by_index(obj_name, i)
			if obj != null and criteria_func.call(obj, _agent):
				outputs.append(obj)
	if outputs.size() > 0:
		if not _closest: 		return outputs[0]
		if _agent == null: 		return outputs[0]
		var agent_pos = _agent.get_tile()
		var ind = 0
		var min_dist = 9999999
		for i in range(outputs.size()):
			var obj = outputs[i]
			var dist = KeyNodes.map().get_distance(obj.get_tile(), agent_pos)
			if dist > 0 and dist < min_dist:
				min_dist = dist
				ind = i
		return outputs[ind]
	
	# if no objects found, return null
	return null

func _criteria_func_agent_can_retrieve(obj, _agent) -> bool:
	return 	KeyNodes.map().get_distance(obj.get_tile(), _agent.get_tile()) > 0 and \
			obj.get_inventory().has_claimable_items("%TEST_ITEM%")

func get_global_task(_agent: Agent) -> Task:
	var _SRC_OBJECTS = [
		"source_box",
		"item_pile",
	]
	var src = find_world_object(_SRC_OBJECTS, _criteria_func_agent_can_retrieve, _agent)
	if src == null: return null
	var tgt = KeyNodes.objMgr().get_object_by_index("target_box")
	var task = task_.new()
	task.initialize_test_task(src, tgt)
	return task

func get_front_agent_task(_agent: Agent) -> Task:
	return task_queue.pop_front()

func get_task(_agent: Agent) -> Task:
	if task_queue.size() == 0:
		var task = get_global_task(_agent)
		if task == null:
			return null
		task_queue.append(task)
		add_child(task)
	return get_front_agent_task(_agent)
