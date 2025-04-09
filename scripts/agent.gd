class_name Agent

extends Node2D

# const map_ = preload("res://scripts/utils/map_utils.gd")

var state = -1
var state_start_time = 0
# 0 - idle
# 1 - moving
# 2 - interacting
# 3 - idle wander

@export var idle_time: int = 500

var cur = Vector2i(0, 0)
var path: Array[Vector2i] = []
var cur_task: Task = null
var queued_interaction_time: int = 0
var queued_interaction_obj: WorldObject = null
var queued_interaction_type: int = -1
var interact_after_move: bool = false

var _id = 0
var _name = "elf"

func get_agent_id() -> int:
	return _id
func get_agent_name() -> String:
	return _name
func get_tile() -> Vector2i:
	return cur

@export var speed: float = 200.0
@export var idle_wander_speed: float = 100.0
var cur_speed = speed

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
	var move_distance = cur_speed * delta
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
	_tp(cur)
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
		cur_task = taskmgr().get_task(self)
		if cur_task == null:
			queue_idle_wander()
			return
	if state == 1 and interact_after_move:
		interact_after_move = false
		state = 2
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
			state = 1
		else:
			print("Unknown subtask type")
			default_idle_state()
			return
		subtask.agent_execute(self)

	render_interact()
	toggleDialog(state == 0)

func get_closest_to_object(obj: WorldObject, interaction_type) -> Vector2i:
	var closest = null
	var closest_dist = 9999999
	for tile in obj.get_tiles_for_interaction(interaction_type):
		var dist = map().get_distance(cur, tile)
		if dist > -1 and dist < closest_dist:
			closest = tile
			closest_dist = dist
	return closest

func queue_idle_wander() -> void:
	print("Idle wander :) No tasks")
	queue_move_to(map().get_random_open_tile())
	cur_speed = idle_wander_speed
	default_idle_state()
	state = 3
	


func queue_interact(obj: WorldObject, interaction_type) -> bool:
	print("Interacting with ", obj.get_obj_name(), obj.get_obj_id(), " ", interaction_type)
	# get interaction time, based on the object and interaction type
	queued_interaction_time = obj.get_time_for_interaction(interaction_type)
	get_progress_bar().max_value = queued_interaction_time
	get_progress_bar().value = (0)

	queued_interaction_obj = obj
	queued_interaction_type = interaction_type

	var found = queue_move_to(get_closest_to_object(obj, interaction_type))
	if found:
		interact_after_move = true
	return found

func queue_move_to(target: Vector2i) -> bool:
	if target == null:
		print("No target")
		return false
	print("Moving to ", target)
	cur_speed = speed
	path = map().get_tile_path(cur, target)
	return path.size() > 0

func _physics_process(delta: float) -> void:
	match state:
		-1: 
			return
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
		3:
			if _physics_move_agent(delta):
				state = 0
				state_start_time = Time.get_ticks_msec()
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
