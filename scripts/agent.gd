class_name Agent

extends Node2D

# const map_ = preload("res://scripts/utils/map_utils.gd")

var state = 0
var state_start_time = 0
# 0 - idle
# 1 - executing task

var cur = Vector2i(0, 0)
var path: Array[Vector2i] = []

var cur_task: Task = null

@export var speed: float = 200.0

func map():
	return get_tree().get_nodes_in_group("map")[0]
func taskmgr():
	return get_tree().get_nodes_in_group("task_manager")[0]

func move_agent(delta) -> bool:
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

func state_transition() -> void:
	state_start_time = Time.get_ticks_msec()
	if state != 0:
		cur_task.start_task()
		cur_task.get_current_subtask().agent_execute(self)
	toggleDialog(state == 0)

func interact(target) -> bool:
	print("Interacting with ", target)
	path = []
	return true
func move_to(target: Vector2i) -> bool:
	print("Moving to ", target)
	path = map().get_astar(cur, target)
	return path.size() > 0

func _physics_process(delta: float) -> void:
	if state == 0 and Time.get_ticks_msec() - state_start_time > 1000:
		state = 1
		cur_task = taskmgr().get_task()
		state_transition()
		return
	if state == 1:
		if move_agent(delta):
			if cur_task.next_subtask():
				cur_task.get_current_subtask().agent_execute(self)
			else:
				state = 0
				state_transition()
		return
