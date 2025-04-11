class_name Agent
extends UniqueActor

# const map_ = preload("res://scripts/utils/map_utils.gd")

var state = -1
var state_start_time = 0
# 0 - idle
# 1 - moving
# 2 - interacting
# 3 - idle wander

@export var idle_time: int = 500
@export var start_tile: Vector2i = Vector2i(0, 0)
@export var debug_color: Color = Color(1, 0, 0, 1)

var path: Array[Vector2i] = []
var cur_task: Task = null
var queued_interaction_time: int = 0
var queued_interaction_obj: WorldObject = null
var queued_interaction_type: int = -1
var interact_after_move: bool = false

@export var speed: float = 200.0
@export var idle_wander_speed: float = 100.0
var cur_speed = speed

func _init() -> void:
	init_unique_actor()
	_config_agent()

func _config_agent() -> void:
	set_u_name("Elf")

func _physics_move_agent(delta) -> bool:
	var cur_pos = position
	if path.size() == 0:
		return true
	var next_pos = KeyNodes.map().get_world_pos(path[0])
	var move_dir = (next_pos - cur_pos).normalized()
	var distance = (next_pos - cur_pos).length()
	var move_distance = cur_speed * delta
	if distance <= move_distance:
		position = next_pos
		set_tile(path.pop_at(0))
		return path.size() == 0
	position += move_dir * move_distance
	return false

func _tp(tgt: Vector2i) -> void:
	set_tile(tgt)
	position = KeyNodes.map().get_world_pos(get_tile())

func start_tasks() -> void:
	state_start_time = Time.get_ticks_msec()
	_tp(get_tile())
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
		cur_task = KeyNodes.taskMgr().get_task(self)
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
		id_print("Task finished")
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


func queue_idle_wander() -> void:
	id_print("Idle wander :) No tasks")
	queue_move_to(KeyNodes.map().get_random_open_tile())
	cur_speed = idle_wander_speed
	default_idle_state()
	state = 3
	


func queue_interact(obj: WorldObject, interaction_type) -> bool:
	id_print("Interacting with "+obj.debug_str()+" "+str(interaction_type))
	# get interaction time, based on the object and interaction type
	queued_interaction_time = obj.get_time_for_interaction(interaction_type)
	get_progress_bar().max_value = queued_interaction_time
	get_progress_bar().value = (0)

	queued_interaction_obj = obj
	queued_interaction_type = interaction_type

	var found = queue_move_to(obj.get_closest_interaction_tile(get_tile(), interaction_type))
	if found:
		interact_after_move = true
		# if interaction_type == obj.OBJ_INTERACTION_TYPE.RETRIEVE_ITEM:
			# found = obj.get_inventory().claim_item("%TEST_ITEM%", self)
	return found

func queue_move_to(target: Vector2i) -> bool:
	if target == null:
		print("No target")
		return false
	id_print("Moving to " + str(target))
	cur_speed = speed
	path = KeyNodes.map().get_tile_path(get_tile(), target)
	debug_draw_path()
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

func get_progress_bar():			return $ProgressBar
func get_debug_path_line2d():		return $Debug/PathNode/Path

func debug_draw_path():
	var path_line = get_debug_path_line2d()
	path_line.clear_points()
	for i in range(path.size()):
		var tile = path[i]
		var world_pos = KeyNodes.map().get_world_pos(tile)
		path_line.add_point(world_pos)
	path_line.default_color = debug_color
