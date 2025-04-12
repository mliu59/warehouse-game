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

	valid = valid and _add_subtask(agent_params, retrieve_params, interaction_params, ObjInteractionConsts.TYPE.RETRIEVE_ITEM)
	valid = valid and _add_subtask(agent_params, deposit_params, interaction_params, ObjInteractionConsts.TYPE.DEPOSIT_ITEM)

func _add_subtask(
	src_params: Dictionary, 
	tgt_params: Dictionary, 
	interaction_params: Dictionary, 
	interaction_type: ObjInteractionConsts.TYPE
) -> bool:
	var subtask = Subtask.new()
	add_child(subtask)
	subtasks_.append(subtask)
	return subtask.init(src_params, tgt_params, interaction_params, interaction_type, self)


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

func started() -> bool:
	return current_task_index_ != -1

func start_task() -> bool:
	if not started():
		# print("Task started")
		current_task_index_ = 0
		return false
	return true
	
func get_current_subtask() -> Subtask:
	# print("Current subtask: ", current_task_index_)
	return subtasks_[current_task_index_]

# Returns true if there are more subtasks to execute
func get_next_subtask() -> bool:
	# print("Next subtask, incrementing index")
	subtasks_[current_task_index_].mark_completed()
	current_task_index_ += 1
	return current_task_index_ < subtasks_.size()

func finished() -> bool:
	return current_task_index_ >= subtasks_.size()

func has_next_subtask() -> bool:
	return current_task_index_ + 1 < subtasks_.size()
