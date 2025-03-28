extends Node
class_name WorldObject

var atlas_pos_: Vector2i = Vector2i(6, 2)
var interact_directions_: Array = []
var pos_: Vector2i = Vector2i(0, 0)

var interactable_: bool = len(interact_directions_) > 0
var passable_: bool = false

func get_tile() -> Vector2i:
	return pos_

