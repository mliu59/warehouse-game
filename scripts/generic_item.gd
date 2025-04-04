extends Node
class_name GenericItem

@export var item_id: String = "%TEST_ITEM%"
@export var item_weight: int = 0

func get_id() -> String:
	return item_id

func get_weight() -> int:
	return item_weight
