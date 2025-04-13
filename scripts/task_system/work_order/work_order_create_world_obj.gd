extends BaseWorkOrder
class_name WorkOrderCreateWorldObject


func queue_execute() -> void:
	var agent = get_params().get("agent")
	var t = 0
	if not get_params().get("virtual", false):
		t = get_params().get("duration", 0)
	
	agent.set_interaction_time(t)

func execute() -> bool:
	var obj_id: String = get_params().get("obj_id")
	var tile: Vector2i = get_params().get("tgt_tile")
	var virtual: bool = get_params().get("virtual", false)
	
	var node = KeyNodes.objMgr().add_world_object(obj_id, tile, virtual)
	return node != null

func start_agent_state() -> Agent.AGENT_STATE:
	return Agent.AGENT_STATE.INTERACTING
