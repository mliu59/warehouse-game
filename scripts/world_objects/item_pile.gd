extends WorldObject
class_name ItemPile
# This is a source box that can be used to spawn items in the world.
# It is a type of world object that can be interacted with by agents.

func config_object() -> void:
	_name = "item_pile"
	interactable_ = true
	allowed_interaction_types_ = [
		OBJ_INTERACTION_TYPE.RETRIEVE_ITEM,
		OBJ_INTERACTION_TYPE.DEPOSIT_ITEM	
	]
	interaction_directions_ = {
		OBJ_INTERACTION_TYPE.RETRIEVE_ITEM: MapUtils.ADJ_TILES_8,
		OBJ_INTERACTION_TYPE.DEPOSIT_ITEM: MapUtils.ADJ_TILES_8
	}
	atlas_pos_ = Vector2i(7, 2)
	# hide_inventory_ = true
	destroy_on_empty_inventory_ = true
