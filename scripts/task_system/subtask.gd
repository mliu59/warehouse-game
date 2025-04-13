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
func is_drop_item() -> bool: return get_interaction_type() == ObjInteractionConsts.TYPE.DROP_ITEM

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

# check if the task is valid (correct params, etc.)
func _check_valid() -> bool:
	if get_interaction_type() == ObjInteractionConsts.TYPE.NULL_INTERACTION: 									return false
	# any src/tgt params MUST contain a check for object class
	if not _dict_includes(_src_params, ["class"]):																return false
	if not _dict_includes(_tgt_params, ["class"]):																return false
	if not _dict_includes(_interaction_params, ["type"]):														return false

	if _tgt_params["class"] is WorldObject and not _dict_includes(_tgt_params, ["actor_id"]): 					return false
	# any inventory transfer interaction must specify item id and item qty
	if is_inventory_transfer() and not _dict_includes(_interaction_params, ["item_id", "item_qty"]):			return false
	if is_drop_item() and not _dict_includes(_interaction_params, ["item_id", "item_qty"]):						return false

	return true

func _verify_src_agent(_agent: Agent) -> bool:
	# check if agent is of the right class
	# if not _agent is (_src_params["class"]): 										return false
	return true

func if_agent_can_execute(agent: Agent) -> bool:
	# check if agent can execute the task
	if not _verify_src_agent(agent): 																			return false

	if is_inventory_transfer():
		var tgt_obj_list = KeyNodes.objMgr().find_reachable_world_object(_tgt_params, _interaction_params, agent, true)
		if tgt_obj_list.size() == 0: 																			return false

	if is_drop_item():
		var tiles_list = KeyNodes.map().get_tiles_for_interaction(_tgt_params, _interaction_params, agent)
		if tiles_list.size() == 0: 																				return false

	return true



var _completed: bool = false

var work_orders: Array = []
var work_order_index: int = -1

func get_next_work_order() -> void:
	if work_order_index >= 0: work_orders[work_order_index].mark_completed()
	work_order_index += 1
	if work_order_index >= work_orders.size(): mark_completed()
func get_current_work_order() -> BaseWorkOrder:
	if work_order_index >= 0 and work_order_index < work_orders.size():
		return work_orders[work_order_index]
	return null
func mark_completed() -> void:
	_completed = true
	for work_order in work_orders:
		work_order.mark_completed()
func finished() -> bool:
	return _completed



func _add_work_order(work_order: BaseWorkOrder, type: BaseWorkOrder.WORK_ORDER_TYPE, params: Dictionary) -> void:
	work_order.init(type, params)
	work_orders.append(work_order)
	add_child(work_order)

func generate_work_order(agent: Agent) -> bool:
	if is_inventory_transfer():
		var tgt_obj_list = KeyNodes.objMgr().find_reachable_world_object(_tgt_params, _interaction_params, agent, false)
		if tgt_obj_list.size() == 0: 													return false
		var min_dist = 9999999
		var tgt_obj = null
		for i in range(tgt_obj_list.size()):
			var obj = tgt_obj_list[i]
			var dist = KeyNodes.map().get_distance(obj.get_tile(), agent.get_tile())
			if dist > 0 and dist < min_dist:
				min_dist = dist
				tgt_obj = obj
		
		_add_work_order(WorkOrderMove.new(), BaseWorkOrder.WORK_ORDER_TYPE.MOVE_TO, {
			"agent": agent,
			"tgt": tgt_obj.get_closest_interaction_tile(agent.get_tile(), get_interaction_type()),
		})
		
		var inv_transfer_params = {
			"agent": agent,
			"src": agent,
			"tgt": tgt_obj,
		}
		inv_transfer_params.merge(_interaction_params)

		if get_interaction_type() == ObjInteractionConsts.TYPE.RETRIEVE_ITEM:
			var reserved_items = tgt_obj.get_inventory().claim_items(_interaction_params["item_id"], _interaction_params["item_qty"], _parent_task)
			inv_transfer_params["reserved_items"] = reserved_items
			for item in reserved_items:
				item.set_reserved(true, _parent_task)
			var temp = inv_transfer_params["src"]
			inv_transfer_params["src"] = inv_transfer_params["tgt"]
			inv_transfer_params["tgt"] = temp
			_add_work_order(WorkOrderInteract.new(), BaseWorkOrder.WORK_ORDER_TYPE.INVENTORY_TRANSFER_RETRIEVE, inv_transfer_params)
		else:
			_add_work_order(WorkOrderInteract.new(), BaseWorkOrder.WORK_ORDER_TYPE.INVENTORY_TRANSFER_DEPOSIT, inv_transfer_params)
	
	if is_drop_item():
		var drop_params = {
			"agent": agent,
			"src": agent,
			"obj_id": "item_pile",
			"virtual": true,
		}
		drop_params.merge(_interaction_params)
		drop_params.merge(_tgt_params)
		var temp_item_pile = load(KeyNodes.objMgr().world_object_dict["item_pile"]).instantiate()
		temp_item_pile.set_tile(drop_params.get("tgt_tile"))

		_add_work_order(WorkOrderCreateWorldObject.new(), BaseWorkOrder.WORK_ORDER_TYPE.CREATE_WORLD_OBJECT, drop_params)
		_add_work_order(WorkOrderMove.new(), BaseWorkOrder.WORK_ORDER_TYPE.MOVE_TO, {
			"agent": agent,
			"tgt": temp_item_pile.get_closest_interaction_tile(agent.get_tile(), get_interaction_type()),
		})
		_add_work_order(WorkOrderInteract.new(), BaseWorkOrder.WORK_ORDER_TYPE.INVENTORY_TRANSFER_DEPOSIT, drop_params)



	return true



# func execute_interact() -> bool:
# 	if is_inventory_transfer():
# 		var src = _subtask_work_order["src"].get_inventory()
# 		var tgt = _subtask_work_order["tgt"].get_inventory()
# 		if get_interaction_type() == ObjInteractionConsts.TYPE.RETRIEVE_ITEM:
# 			var temp = src
# 			src = tgt
# 			tgt = temp
# 			return src.transfer_reserved_items_to(tgt, _subtask_work_order["reserved_items"])
# 		return src.transfer_items_to(tgt, _interaction_params)
		
# 	return true

# func agent_queue_execute(agent: Agent) -> bool:
# 	var obj = _subtask_work_order["tgt"]
# 	if obj == null: return false
# 	agent.id_print("Interacting with "+obj.debug_str()+" "+str(get_interaction_type()))

# 	if _dict_includes(_interaction_params, ["duration"]) and _interaction_params["duration"] > 0:
# 		agent.set_interaction_time(_interaction_params["duration"])

# 	agent.queue_move_to(obj.get_closest_interaction_tile(agent.get_tile(), get_interaction_type()))
# 	agent.interact_after_move = true

# 	return true
