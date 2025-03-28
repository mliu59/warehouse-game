extends Node2D

var started_process = false
var state = 0
var state_start_time = Time.get_ticks_msec()
# 0 - idle
# 1 - get item
# 2 - deposit item

var src = Vector2i(0, 0)
var dest = Vector2i(0, 0)
var cur = Vector2i(0, 0)
var path: Array[Vector2i] = []

@export var speed: float = 100.0

func start_test_task(source: Vector2i, target: Vector2i, spawn: Vector2i) -> void:
	cur = spawn
	position = get_tree().get_nodes_in_group("map")[0].get_world_pos(spawn)
	src = source
	dest = target
	started_process = true
	state = 0
	toggleDialog(true)

func toggleDialog(en: bool):
	$StatusDialog.visible = en

func state_transition(_dest) -> void:
	# print("state transition", _dest, state, cur)
	state_start_time = Time.get_ticks_msec()
	var map_node = get_tree().get_nodes_in_group("map")[0]
	path = map_node.get_astar(cur, _dest)
	# for p in astar_path:
		# path.append(map_node.get_world_pos(p))
	toggleDialog(state == 0)
	print(state)
	print(path)

func _physics_process(delta: float) -> void:
	if not started_process:
		return
	if state == 0 and Time.get_ticks_msec() - state_start_time > 1000:
		state = 1
		state_transition(src)
		return

	if state == 1:
		var cur_pos = position
		var next_pos = get_tree().get_nodes_in_group("map")[0].get_world_pos(path[0])
		var move_dir = (next_pos - cur_pos).normalized()
		var distance = (next_pos - cur_pos).length()
		var move_distance = speed * delta
		if distance <= move_distance:
			position = next_pos
			cur = path.pop_at(0)
			if path.size() == 0:
				state = 2
				state_transition(dest)
		else:
			position += move_dir * move_distance

	if state == 2:
		var cur_pos = position
		var next_pos = get_tree().get_nodes_in_group("map")[0].get_world_pos(path[0])
		var move_dir = (next_pos - cur_pos).normalized()
		var distance = (next_pos - cur_pos).length()
		var move_distance = speed * delta
		if distance <= move_distance:
			position = next_pos
			cur = path.pop_at(0)
			if path.size() == 0:
				state = 0
				state_transition(src)
		else:
			position += move_dir * move_distance
