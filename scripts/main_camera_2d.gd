extends Camera2D

func center_camera_for_map(_map) -> void:
	var cur_center = get_screen_center_position()
	var map_center = _map.map_center_pixels
	set_offset(map_center - cur_center)
