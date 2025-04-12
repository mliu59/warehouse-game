extends Node
class_name Subtask

# template subtask 

# current supported interactions:
# retrieve item, deposit item (inventory exchanges)
# TODO: creation of items, transformation of items

var _src_params: Dictionary = {}
var _tgt_params: Dictionary = {}
var _interaction_params: Dictionary = {}

var _interaction_type: ObjInteractionConsts.TYPE = ObjInteractionConsts.TYPE.NULL_INTERACTION

var _parent_task: Task = null

func get_interaction_type() -> ObjInteractionConsts.TYPE: return _interaction_type
func is_inventory_transfer() -> bool: return get_interaction_type() in [ObjInteractionConsts.TYPE.RETRIEVE_ITEM, ObjInteractionConsts.TYPE.DEPOSIT_ITEM]
func _dict_includes(dict:Dictionary, keys: Array[String]) -> bool:
	for key in keys:
		if not dict.has(key): return false
	return true

func init(src_params, tgt_params, interaction_params, interaction_type, parent_task: Task) -> bool:
	_src_params = src_params.duplicate()
	_tgt_params = tgt_params.duplicate()
	_interaction_params = interaction_params.duplicate()
	_interaction_type = interaction_type
	_interaction_params["type"] = interaction_type
	_parent_task = parent_task

	return _check_valid()

func _check_valid() -> bool:
	if get_interaction_type() == ObjInteractionConsts.TYPE.NULL_INTERACTION: 		return false
	# any src/tgt params MUST contain a check for object class
	if not _dict_includes(_src_params, ["class"]):									return false
	if not _dict_includes(_tgt_params, ["class"]):									return false
	if not _dict_includes(_interaction_params, ["type"]):							return false

	if _tgt_params["class"] is WorldObject and not _dict_includes(_tgt_params, ["actor_id"]): return false
	# any inventory transfer interaction must specify item id and item qty
	if is_inventory_transfer() and not _dict_includes(_interaction_params, ["item_id", "item_qty"]):		return false

	return true

func _verify_src_agent(_agent: Agent) -> bool:
	# check if agent is of the right class
	# if not _agent is (_src_params["class"]): 										return false
	return true

func if_agent_can_execute(agent: Agent) -> bool:
	# check if agent can execute the task
	if not _verify_src_agent(agent): 												return false
	var tgt_obj_list = KeyNodes.objMgr().find_reachable_world_object(_tgt_params, _interaction_params, agent, true)
	if tgt_obj_list.size() == 0: 													return false

	return true



var completed: bool = false
var _subtask_work_order: Dictionary = {
	"src": null,
	"tgt": null,
	"reserved_items": []
}

func generate_work_order(agent: Agent) -> bool:
	_subtask_work_order["src"] = agent
	var tgt_obj_list = KeyNodes.objMgr().find_reachable_world_object(_tgt_params, _interaction_params, agent, false)
	if tgt_obj_list.size() == 0: 													return false
	var min_dist = 9999999
	for i in range(tgt_obj_list.size()):
		var obj = tgt_obj_list[i]
		var dist = KeyNodes.map().get_distance(obj.get_tile(), agent.get_tile())
		if dist > 0 and dist < min_dist:
			min_dist = dist
			_subtask_work_order["tgt"] = obj
	if _subtask_work_order["tgt"] == null: 											return false


	if get_interaction_type() == ObjInteractionConsts.TYPE.RETRIEVE_ITEM:
		var reserved_items = _subtask_work_order["tgt"].get_inventory().claim_items(_interaction_params["item_id"], _interaction_params["item_qty"], _parent_task)
		if reserved_items.size() == 0: 												return false
		_subtask_work_order["reserved_items"] = reserved_items
		for item in reserved_items:
			item.set_reserved(true, _parent_task)
	
	return true


func mark_completed() -> void:
	completed = true
	for item in _subtask_work_order["reserved_items"]:
		item.set_reserved(false, null)
	_subtask_work_order["reserved_items"].clear()

func execute_interact() -> bool:
	if is_inventory_transfer():
		var src = _subtask_work_order["src"].get_inventory()
		var tgt = _subtask_work_order["tgt"].get_inventory()
		if get_interaction_type() == ObjInteractionConsts.TYPE.RETRIEVE_ITEM:
			var temp = src
			src = tgt
			tgt = temp
			return src.transfer_reserved_items_to(tgt, _subtask_work_order["reserved_items"])
		return src.transfer_items_to(tgt, _interaction_params)
		
	return true

func agent_queue_execute(agent: Agent) -> bool:
	var obj = _subtask_work_order["tgt"]
	if obj == null: return false
	agent.id_print("Interacting with "+obj.debug_str()+" "+str(get_interaction_type()))

	if _dict_includes(_interaction_params, ["duration"]) and _interaction_params["duration"] > 0:
		agent.set_interaction_time(_interaction_params["duration"])

	agent.queue_move_to(obj.get_closest_interaction_tile(agent.get_tile(), get_interaction_type()))
	agent.interact_after_move = true

	return true
