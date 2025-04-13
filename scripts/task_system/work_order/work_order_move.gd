extends BaseWorkOrder
class_name WorkOrderMove

func queue_execute() -> void:
	var agent = get_params().get("agent")
	var tgt_tile = get_params().get("tgt")

	agent.queue_move_to(tgt_tile)


func start_agent_state() -> Agent.AGENT_STATE:
	return Agent.AGENT_STATE.MOVING