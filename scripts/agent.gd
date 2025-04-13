class_name Agent
extends UniqueActor

# const map_ = preload("res://scripts/utils/map_utils.gd")

var state = -1
var state_start_time = 0
# 0 - idle
# 1 - moving
# 2 - interacting
# 3 - idle wander

enum AGENT_STATE {
	IDLE = 0,
	MOVING = 1,
	INTERACTING = 2,
	IDLE_WANDER = 3
}

@export var idle_time: int = 500
@export var start_tile: Vector2i = Vector2i(0, 0)
@export var debug_color: Color = Color(1, 0, 0, 1)

var path: Array[Vector2i] = []
var cur_task: Task = null
var cur_work_order: BaseWorkOrder = null
var queued_interaction_time: int = 0

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
	state = AGENT_STATE.IDLE
	toggleDialog(true)



func default_idle_state() -> void:
	state = AGENT_STATE.IDLE
	render_interact()
	toggleDialog(true)

func state_transition() -> void:
	state_start_time = Time.get_ticks_msec()
	if cur_task == null:
		cur_task = KeyNodes.taskMgr().get_available_task(self)
		if cur_task == null:
			queue_idle_wander()
			return

	cur_task.get_next_work_order()
	if cur_task.finished():
		id_print("Task finished")
		cur_task = null
		state = AGENT_STATE.IDLE
	else:
		cur_work_order = cur_task.get_current_work_order()
		state = cur_work_order.start_agent_state()
		cur_work_order.queue_execute()

	render_interact()
	toggleDialog(state == AGENT_STATE.IDLE)


func set_interaction_time(time: int) -> void:
	queued_interaction_time = time
	get_progress_bar().max_value = queued_interaction_time
	get_progress_bar().value = (0)


func queue_idle_wander() -> void:
	id_print("Idle wander :) No tasks")
	queue_move_to(KeyNodes.map().get_random_open_tile())
	cur_speed = idle_wander_speed
	state = AGENT_STATE.IDLE_WANDER
	render_interact()
	_render_dialog_state()

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
		AGENT_STATE.IDLE: # idle, Check if the agent is idle for too long
			if Time.get_ticks_msec() - state_start_time > idle_time:
				state_transition()
			return
		AGENT_STATE.MOVING: # moving, Move the agent
			if _physics_move_agent(delta):
				state_transition()
			return
		AGENT_STATE.INTERACTING: # interacting, Interact with the object
			render_interact()
			if Time.get_ticks_msec() - state_start_time > queued_interaction_time:
				cur_work_order.execute()
				state_transition()
			return
		AGENT_STATE.IDLE_WANDER:
			# return
			if _physics_move_agent(delta):
				state = AGENT_STATE.IDLE
				state_start_time = Time.get_ticks_msec()
				_render_dialog_state()
			return
		_:
			print("ERRR")
	return



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


func get_status_dialog(): return $StatusDialog

func _render_dialog_state() -> void:
	for dialog in get_status_dialog().get_children():
		dialog.visible = false
	if state == 0:
		get_status_dialog().get_node("thinking").visible = true
	elif state == 3:
		get_status_dialog().get_node("wandering").visible = true

func toggleDialog(en: bool):
	get_status_dialog().visible = en

func render_interact():
	if state == 2:
		get_progress_bar().value = float(Time.get_ticks_msec() - state_start_time)
		get_progress_bar().visible = true
	else:
		get_progress_bar().visible = false
