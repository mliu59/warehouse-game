extends WorldObject
class_name TargetBox


func config_object() -> void:
	_name = "target_box"
	interactable_ = true
	allowed_interaction_types_ = [OBJ_INTERACTION_TYPE.DEPOSIT_ITEM]
	interaction_directions_ = {
		OBJ_INTERACTION_TYPE.DEPOSIT_ITEM: MapUtils.ADJ_TILES_8
	}
	atlas_pos_ = Vector2i(0, 2)
