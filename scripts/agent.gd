class_name Agent

extends Node2D

# const map_ = preload("res://scripts/utils/map_utils.gd")

var state = 0
var state_start_time = 0
# 0 - idle
# 1 - moving
# 2 - interacting

@export var idle_time: int = 500

var cur = Vector2i(0, 0)
var path: Array[Vector2i] = []
var cur_task: Task = null
var queued_interaction_time: int = 0
var queued_interaction_obj: WorldObject = null
var queued_interaction_type: int = -1

@export var speed: float = 200.0

func map():
	return get_node("/root/Main").get_map()
func objMgr():
	return get_node("/root/Main").get_object_manager()
func taskmgr():
	return get_node("/root/Main").get_task_manager()

func _physics_move_agent(delta) -> bool:
	var cur_pos = position
	if path.size() == 0:
		return true
	var next_pos = map().get_world_pos(path[0])
	var move_dir = (next_pos - cur_pos).normalized()
	var distance = (next_pos - cur_pos).length()
	var move_distance = speed * delta
	if distance <= move_distance:
		position = next_pos
		cur = path.pop_at(0)
		return path.size() == 0
	position += move_dir * move_distance
	return false

func _tp(tgt: Vector2i) -> void:
	cur = tgt
	position = map().get_world_pos(cur)

func start_tasks() -> void:
	state_start_time = Time.get_ticks_msec()
	_tp(map().spawn_point)
	state = 0
	toggleDialog(true)

func toggleDialog(en: bool):
	$StatusDialog.visible = en

func default_idle_state() -> void:
	state = 0
	render_interact()
	toggleDialog(true)

func state_transition() -> void:
	state_start_time = Time.get_ticks_msec()
	if cur_task == null:
		cur_task = taskmgr().get_task()
		if cur_task == null:
			print("No task available")
			default_idle_state()
			return
	if cur_task.start_task():
		cur_task.get_next_subtask()
	if cur_task.finished():
		print("Task finished")
		cur_task = null
		state = 0
	else:
		var subtask = cur_task.get_current_subtask()
		if subtask.get_subtask_type() == subtask.SubtaskType.MOVE_TO:
			state = 1
		elif subtask.get_subtask_type() == subtask.SubtaskType.INTERACT:
			state = 2
		else:
			print("Unknown subtask type")
			default_idle_state()
			return
		subtask.agent_execute(self)

	render_interact()
	toggleDialog(state == 0)

func queue_interact(obj: WorldObject, interaction_type) -> bool:
	print("Interacting with ", obj.get_obj_name(), obj.get_obj_id(), " ", interaction_type)
	# get interaction time, based on the object and interaction type
	queued_interaction_time = obj.get_time_for_interaction(interaction_type)
	get_progress_bar().max_value = queued_interaction_time
	get_progress_bar().value = (0)

	queued_interaction_obj = obj
	queued_interaction_type = interaction_type
	path = []
	return true
func queue_move_to(target: Vector2i) -> bool:
	print("Moving to ", target)
	path = map().get_astar(cur, target)
	return path.size() > 0

func _physics_process(delta: float) -> void:
	match state:
		0: # idle, Check if the agent is idle for too long
			if Time.get_ticks_msec() - state_start_time > idle_time:
				state_transition()
			return
		1: # moving, Move the agent
			if _physics_move_agent(delta):
				state_transition()
			return
		2: # interacting, Interact with the object
			render_interact()
			if Time.get_ticks_msec() - state_start_time > queued_interaction_time:
				trigger_interact()
				state_transition()
			return
		_:
			print("ERRR")

func render_interact():
	if state == 2:
		#print(float(Time.get_ticks_msec() - state_start_time) / queued_interaction_time)
		get_progress_bar().value = float(Time.get_ticks_msec() - state_start_time)
		get_progress_bar().visible = true
	else:
		get_progress_bar().visible = false

func trigger_interact() -> void:
	if queued_interaction_obj == null:
		print("No object to interact with")
		return
	if queued_interaction_type == -1:
		print("No interaction type")
		return

	queued_interaction_obj.interact(self, queued_interaction_type)

	queued_interaction_obj = null
	queued_interaction_type = -1

func get_inventory():
	return $GenericInventory
func get_progress_bar():
	return $ProgressBar

func get_inventory_counter():
	return $TEST_ITEM_COUNTER
func _on_inventory_changed():
	get_inventory_counter().set_text(str(get_inventory().get_inventory_size()))
