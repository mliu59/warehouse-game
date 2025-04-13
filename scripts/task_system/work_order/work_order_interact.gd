extends BaseWorkOrder
class_name WorkOrderInteract

func queue_execute() -> void:
	var agent = get_params().get("agent")
	agent.set_interaction_time(get_params().get("duration", 0))


func execute() -> bool:
	if "src" not in get_params() and "src_tile" in get_params():
		get_params().set("src", KeyNodes.objMgr().find_world_object_by_tile(get_params().get("src_tile")))
	if "tgt" not in get_params() and "tgt_tile" in get_params():
		get_params().set("tgt", KeyNodes.objMgr().find_world_object_by_tile(get_params().get("tgt_tile")))
	var src = get_params().get("src").get_inventory()
	var tgt = get_params().get("tgt").get_inventory()

	if get_work_order_type() in [WORK_ORDER_TYPE.INVENTORY_TRANSFER_RETRIEVE, WORK_ORDER_TYPE.INVENTORY_TRANSFER_DEPOSIT]:
		var obj_node = tgt.get_parent()
		if obj_node != null and obj_node is WorldObject:
			obj_node.set_virtual(false)
		if get_work_order_type() == WORK_ORDER_TYPE.INVENTORY_TRANSFER_RETRIEVE:
			return src.transfer_reserved_items_to(tgt, get_params().get("reserved_items"))
		if get_work_order_type() == WORK_ORDER_TYPE.INVENTORY_TRANSFER_DEPOSIT:
			return src.transfer_items_to(tgt, get_params())

	return false

func start_agent_state() -> Agent.AGENT_STATE:
	return Agent.AGENT_STATE.INTERACTING
