extends Node2D
class_name GenericInventory

const _genericItem = preload("res://scripts/generic_item.gd")

@export var max_inventory_size: int = 100
@export var max_inventory_weight: int = 100
var inventory: Dictionary = {}
var inventory_weight: int = 0
var inventory_size: int = 0

signal inventory_changed

func get_inventory_size() -> int:		return inventory_size
func is_empty() -> bool:				return inventory_size == 0
func get_counter() -> Label: 			return $TEST_ITEM_COUNTER
func update_counter() -> void:			get_counter().set_text(str(get_inventory_size()))

func _inventory_changed() -> void:
	inventory_changed.emit()
	update_counter()

func add_item(obj: GenericItem) -> bool:
	var id = obj.get_id()
	var weight = obj.get_weight()
	if inventory_size + 1 > max_inventory_size or inventory_weight + weight > max_inventory_weight:
		return false
	if not inventory.has(id):
		inventory[id] = []
	add_child(obj)
	inventory[id].append(obj)	
	inventory_weight += weight
	inventory_size += 1
	_inventory_changed()
	return true

func remove_item(id: String, qty:int) -> Array:
	if qty <= 0:
		return []
	if not inventory.has(id) or inventory[id].size() < qty:
		return []
	var output = []
	for i in range(qty):
		var item = inventory[id].pop_at(0)
		output.append(item)
		remove_child(item)
	inventory_weight -= output[0].get_weight() * qty
	inventory_size -= qty
	if inventory[id].size() == 0:
		inventory.erase(id)
	_inventory_changed()
	return output

func clear_inventory() -> void:
	inventory.clear()
	for item in get_children():
		if item is GenericItem:
			remove_child(item)
	inventory_weight = 0
	inventory_size = 0
	_inventory_changed()

func get_item_count(id: String) -> int:
	if not inventory.has(id):
		return 0
	return inventory[id].size()

func transfer_item_to(target:GenericInventory, id: String, qty:int) -> bool:
	if not inventory.has(id) or inventory[id].size() < qty:
		return false
	var items = remove_item(id, qty)
	for item in items:
		if not target.add_item(item):
			add_item(item)
			get_parent().id_print("Failed to transfer item, adding back to source inventory")
			return false
	get_parent().id_print("Transferred "+str(qty)+" items of id "+id+" to target inventory")
	get_parent().id_print("Source inventory size: "+str(inventory_size)+" Target inventory size: "+str(target.inventory_size))
	return true


func has_claimable_items(id: String) -> bool:
	if is_empty(): return false
	if not inventory.has(id): return false
	if inventory[id].size() == 0: return false
	for item in inventory[id]:
		if not item.is_claimed():
			return true
	return false

func claim_item(id: String, _agent: Agent) -> bool:
	if not has_claimable_items(id): return false
	for item in inventory[id]:
		if item.claim_item(_agent):
			return true
	return false
