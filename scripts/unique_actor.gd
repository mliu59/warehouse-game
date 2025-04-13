extends Node2D
class_name UniqueActor

# This script is a virtual class for unique actors that can interact with world objects in the game.
# A unique actor has:
# - a unique ID
# - a name
# - a position on the map
# - an inventory

var _id: int = 0
var _name: String = "UniqueActor"
var _pos: Vector2i = Vector2i(-1, -1)

func get_tile() -> Vector2i:				return _pos
func get_u_id() -> int:						return _id
func get_u_name() -> String:				return _name
func set_tile(tile: Vector2i) -> void:		_pos = tile
func set_u_id(id: int) -> void:				_id = id
func set_u_name(input: String) -> void:		_name = input

func get_inventory():						return $GenericInventory	

var _show_items: bool = true
func show_items() -> bool:					return _show_items
func init_unique_actor() -> void:
	if self is WorldObject:		_show_items = false
	IdManager.assign_id(self)
	if not has_node("GenericInventory"):
		var inventory_obj = load("res://scenes/generic_inventory.tscn").instantiate()
		add_child(inventory_obj)
	
func debug_str() -> String:
	return str(_id) + "," + _name + ":" + str(_pos)

func id_print(_str: String) -> void:
	print(debug_str() + ": " + _str)

func disable_processing() -> void: #not being triggered... 
	# Disable processing for this actor
	set_process(false)
	set_physics_process(false)
	set_process_input(false)
	set_process_unhandled_input(false)
	set_process_unhandled_key_input(false)
