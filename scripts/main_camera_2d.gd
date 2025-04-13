extends Camera2D

var moveable: bool = false

func center_cam() -> void:
	if get_parent() == null:					return
	if get_parent() == KeyNodes.map():
		_center_camera_for_map(KeyNodes.map())
	elif get_parent() is Node2D:
		moveable = true
		_center_camera_on_node(get_parent())

	if moveable:
		set_process(false)

func _center_camera_for_map(_map) -> void:
	var cur_center = get_screen_center_position()
	var map_center = _map.map_center_pixels
	set_offset(map_center - cur_center)

func _center_camera_on_node(node: Node2D) -> void:
	pass
	#var cur_center = get_screen_center_position()
	#var node_center = node.position
	#set_offset(node_center + cur_center)

@export var zoom_speed = 0.1
@export var move_scale = 200
@export var max_zoom = 4.0
@export var min_zoom = 1.0

func _process(delta: float) -> void:
	# Handle zoom
	if Input.is_action_pressed("zoom_in"):  # Q
		var cur = zoom.x
		var dz = clamp(cur - zoom_speed, min_zoom, max_zoom)
		zoom = Vector2(dz, dz)
		return
	if Input.is_action_pressed("zoom_out"):  # E
		var cur = zoom.x
		var dz = clamp(cur + zoom_speed, min_zoom, max_zoom)
		zoom = Vector2(dz, dz)
		return
		
	var move_speed = move_scale * delta
	
	# Handle translation
	if Input.is_action_pressed("ui_left"):  # A
		position.x -= move_speed
	if Input.is_action_pressed("ui_right"):  # D
		position.x += move_speed
	if Input.is_action_pressed("ui_up"):  # W
		position.y -= move_speed
	if Input.is_action_pressed("ui_down"):  # S
		position.y += move_speed

	
