extends Node

var running_id_counter: int = 0
var id_map: Dictionary = {}

func assign_id(actor: UniqueActor) -> void:
	actor._id = running_id_counter
	id_map[running_id_counter] = actor
	running_id_counter += 1
