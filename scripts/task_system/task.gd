class_name Task extends Node

var subtasks_: Array = []
var valid: bool = true

func initialize_test_task() -> void:
	var interaction_params = {
		"item_id": "%TEST_ITEM%",
		"item_qty": 1,
		"duration": 500,
	}
	var agent_params = {
		"class": "Agent",
	}
	var retrieve_params = {
		"class": "WorldObject",
		"actor_id": ["source_box", "item_pile"],
	}
	var deposit_params = {
		"class": "WorldObject",
		"actor_id": ["target_box"]
	}

	_add_subtask(agent_params, retrieve_params, interaction_params, ObjInteractionConsts.TYPE.RETRIEVE_ITEM)
	_add_subtask(agent_params, deposit_params, interaction_params, ObjInteractionConsts.TYPE.DEPOSIT_ITEM)

func initialize_drop_task() -> void:
	var drop_params = {
		"class": "WorldObject",
		"tgt_tile": Vector2i(6, 11),
	}
	var agent_params = {
		"class": "Agent",
	}
	var interaction_params = {
		"item_id": "%TEST_ITEM%",
		"item_qty": 1,
		"duration": 500,
	}
	var retrieve_params = {
		"class": "WorldObject",
		"actor_id": ["source_box", "item_pile"],
	}
	_add_subtask(agent_params, retrieve_params, interaction_params, ObjInteractionConsts.TYPE.RETRIEVE_ITEM)
	_add_subtask(agent_params, drop_params, interaction_params, ObjInteractionConsts.TYPE.DROP_ITEM)

func _add_subtask(
	src_params: Dictionary, 
	tgt_params: Dictionary, 
	interaction_params: Dictionary, 
	interaction_type: ObjInteractionConsts.TYPE
) -> void:
	var subtask = Subtask.new()
	add_child(subtask)
	subtasks_.append(subtask)
	var subtask_success = subtask.init(src_params, tgt_params, interaction_params, interaction_type, self)
	valid = valid and subtask_success


func if_agent_can_execute(agent: Agent) -> bool:
	# check if agent can execute the task
	if not valid: return false
	for subtask in subtasks_:
		if not subtask.if_agent_can_execute(agent): 
			print("subtask not executable: "	+ str(subtask.get_interaction_type()))
			return false
	return true


func generate_work_order(agent: Agent) -> bool:
	# print("generate work order")
	if not valid: return false
	for subtask in subtasks_:
		if not subtask.generate_work_order(agent): return false
	return true


#WORK ORDER. already determined by the task manager. Separate system as tasks/subtasks
var current_task_index_: int = -1
var _completed: bool = false


func get_current_work_order() -> BaseWorkOrder:
	return subtasks_[current_task_index_].get_current_work_order()

# Returns true if there are more subtasks to execute
func get_next_work_order() -> void:
	if current_task_index_ == -1: 
		current_task_index_ += 1
		subtasks_[current_task_index_].get_next_work_order()
		return
	subtasks_[current_task_index_].get_next_work_order()
	if subtasks_[current_task_index_].finished():
		current_task_index_ += 1
		if current_task_index_ >= subtasks_.size():
			_completed = true
		else:
			subtasks_[current_task_index_].get_next_work_order()
		

func finished() -> bool:
	return _completed
