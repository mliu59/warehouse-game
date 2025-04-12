extends WorldObject
class_name SourceBox
# This is a source box that can be used to spawn items in the world.
# It is a type of world object that can be interacted with by agents.

func config_object() -> void:
	_name = "source_box"
	interactable_ = true
	allowed_interaction_types_ = [ObjInteractionConsts.TYPE.RETRIEVE_ITEM]
	interaction_directions_ = {
		ObjInteractionConsts.TYPE.RETRIEVE_ITEM: MapUtils.ADJ_TILES_8
	}
	atlas_pos_ = Vector2i(7, 1)
