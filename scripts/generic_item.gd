extends Node
class_name GenericItem

@export var item_id: String = "%TEST_ITEM%"
@export var item_weight: int = 0

var claimed_by_agent: Agent = null

func get_id() -> String:
	return item_id

func get_weight() -> int:
	return item_weight

func is_claimed() -> bool:
	return claimed_by_agent != null

func claim_item(_agent: Agent) -> bool:
	if claimed_by_agent == null:
		claimed_by_agent = _agent
		return true
	return false

func clear_claim() -> void:
	claimed_by_agent = null
