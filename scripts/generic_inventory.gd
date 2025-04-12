extends Node2D
class_name GenericInventory


@export var max_inventory_size: int = 100
var inventory: Dictionary = {}
var inventory_size: int = 0

signal inventory_changed

const ITEM_SCENES = [
	"res://scenes/generic_item.tscn",
]
var item_scenes = {}

func _init() -> void:
	for item in ITEM_SCENES:
		var obj = load(item).instantiate()
		item_scenes[obj.get_item_id()] = item
		obj.queue_free()

func get_inventory_size() -> int:		return inventory_size
func is_empty() -> bool:				return inventory_size == 0
func get_counter() -> Label: 			return $TEST_ITEM_COUNTER
func update_counter() -> void:			get_counter().set_text(str(get_inventory_size()))

func _inventory_changed() -> void:
	inventory_changed.emit()
	render_inventory()


func spawn_items(id: String, qty: int = 1) -> void:
	if not item_scenes.has(id):
		print("Item scene not found: "+id)
		return
	for i in range(qty):
		var item = load(item_scenes[id]).instantiate()
		add_item(item)


func _hide_all_items() -> void:
	for item in get_children():
		if item is GenericItem:
			item.visible = false
func _render_first_item() -> void:
	for item in get_children():
		if item is GenericItem:
			item.visible = true
			return

func render_inventory() -> void:
	update_counter()
	_hide_all_items()
	if get_parent().show_items() and not is_empty():
		_render_first_item()


func add_item(obj: GenericItem) -> bool:
	var id = obj.get_item_id()
	if inventory_size + 1 > max_inventory_size:
		return false
	if not inventory.has(id):
		inventory[id] = []
	add_child(obj)
	inventory[id].append(obj)	
	inventory_size += 1
	_inventory_changed()
	return true

func clear_inventory() -> void:
	inventory.clear()
	for item in get_children():
		if item is GenericItem:
			remove_child(item)
	inventory_size = 0
	_inventory_changed()

func get_item_count(id: String) -> int:
	if not inventory.has(id):
		return 0
	return inventory[id].size()

func _remove_item(item):
	remove_child(item)
	inventory[item.get_item_id()].erase(item)
	inventory_size -= 1
	if inventory[item.get_item_id()].size() == 0:
		inventory.erase(item.get_item_id())
	return item

func _add_to_target(target, item):
	if not target.add_item(item):
		add_item(item)
		get_parent().id_print("Failed to transfer item, adding back to source inventory")

func transfer_reserved_items_to(target:GenericInventory, items:Array) -> bool:
	var temp = []
	for item in items:
		if not inventory.has(item.get_item_id()) or inventory[item.get_item_id()].size() == 0:
			continue
		temp.append(_remove_item(item))
	_inventory_changed()
	for item in temp:
		_add_to_target(target, item)
	# get_parent().id_print("Transferred "+str(qty)+" items of id "+id+" to target inventory")
	# get_parent().id_print("Source inventory size: "+str(inventory_size)+" Target inventory size: "+str(target.inventory_size))
	return true

func transfer_items_to(target:GenericInventory, params: Dictionary) -> bool:
	var id = params["item_id"]
	var qty = params["item_qty"]
	var temp = []
	var count = 0
	for item in inventory[id]:
		if item.is_reserved():				continue
		temp.append(_remove_item(item))
		count += 1
		if count >= qty:					break
		if inventory[id].size() == 0:		break
	_inventory_changed()
	for item in temp:
		_add_to_target(target, item)
	return true



func has_claimable_items(id: String, qty: int) -> bool:
	if is_empty(): return false
	if not inventory.has(id): return false
	if inventory[id].size() == 0: return false
	var count = 0
	for item in inventory[id]:
		if not item.is_reserved():
			count += 1
			if count >= qty:
				return true
	return false

func claim_items(id: String, qty: int, task: Task) -> Array:
	var outputs = []
	if not inventory.has(id): return outputs
	for item in inventory[id]:
		if item.is_reserved(): 
			if not item.get_reserved_task() == task:
				continue
		else:
			item.set_reserved(true, task)
		outputs.append(item)
		if outputs.size() >= qty:
			break
	return outputs
