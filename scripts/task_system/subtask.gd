extends Node
class_name Subtask

const _agent = preload("res://scripts/agent.gd")

enum SubtaskType {
	INTERACT,
	MOVE_TO,

	NULL_SUBTASK
}

var subtask_type: SubtaskType = SubtaskType.NULL_SUBTASK
var target: Vector2i = Vector2i(0, 0)

func init(type: SubtaskType, t) -> void:
	subtask_type = type
	target = t

func get_subtask_type() -> SubtaskType:
	return subtask_type

func agent_execute(agent: Agent) -> bool:
	match subtask_type:
		SubtaskType.INTERACT:
			if not agent.interact(target): return false
			return true
		SubtaskType.MOVE_TO:
			if not agent.move_to(target): return false
			return true
		_:
			return false

