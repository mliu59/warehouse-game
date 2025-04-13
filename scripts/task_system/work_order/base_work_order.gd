extends Node
class_name BaseWorkOrder

enum WORK_ORDER_TYPE {
	NULL,
	MOVE_TO,
	INVENTORY_TRANSFER_RETRIEVE,
	INVENTORY_TRANSFER_DEPOSIT,
	CREATE_WORLD_OBJECT
}

var _work_order_type_: WORK_ORDER_TYPE = WORK_ORDER_TYPE.NULL
var _params: Dictionary = {}
var _completed: bool = false

func mark_completed() -> void:
	_completed = true
	_clear_reserved_items()
func is_completed() -> bool:
	return _completed

func execute() -> bool:
	return true

func init(type: WORK_ORDER_TYPE, params: Dictionary) -> void:
	_work_order_type_ = type
	_params = params.duplicate()

func get_work_order_type() -> WORK_ORDER_TYPE:
	return _work_order_type_
func get_params() -> Dictionary:
	return _params

func _clear_reserved_items() -> void:
	if _params.has("reserved_items"):
		for item in _params["reserved_items"]:
			item.set_reserved(false, null)
		_params["reserved_items"].clear()

func start_agent_state() -> Agent.AGENT_STATE:
	return Agent.AGENT_STATE.IDLE
