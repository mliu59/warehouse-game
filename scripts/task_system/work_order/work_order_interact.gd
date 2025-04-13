extends BaseWorkOrder
class_name WorkOrderInteract

func queue_execute() -> void:
	var agent = get_params().get("agent")

	var t = 0
	if get_params().has("duration"):
		t = get_params().get("duration")
	agent.set_interaction_time(t)


func execute() -> bool:
	var src = get_params().get("src")
	var tgt = get_params().get("tgt")

	if get_work_order_type() == WORK_ORDER_TYPE.INVENTORY_TRANSFER_RETRIEVE:
		return src.transfer_reserved_items_to(tgt, get_params().get("reserved_items"))
	if get_work_order_type() == WORK_ORDER_TYPE.INVENTORY_TRANSFER_DEPOSIT:
		return src.transfer_items_to(tgt, get_params())

	return false

func start_agent_state() -> Agent.AGENT_STATE:
	return Agent.AGENT_STATE.INTERACTING
