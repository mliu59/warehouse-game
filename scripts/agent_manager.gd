extends Node

const AGENT_SCENES = [
	"res://scenes/elf.tscn",
]
var agent_scenes = {}

func _init() -> void:
	for agent in AGENT_SCENES:
		var obj = load(agent).instantiate()
		agent_scenes[obj.get_u_name()] = agent
		obj.queue_free()


func add_agent(type: String, tile: Vector2i) -> Agent:
	if agent_scenes.has(type):
		var obj = load(agent_scenes[type]).instantiate()
		add_child(obj)
		obj._tp(tile)
		return obj
	else:
		print("Agent type not found in dictionary")
		return null

func start_tasks() -> void:
	for agent in get_children():
		if agent.is_in_group("agents"):
			agent.start_tasks()

func _ready() -> void:
	for agent in get_children():
		if agent is Agent:
			agent.add_to_group("agents")
			agent._tp(agent.start_tile)
