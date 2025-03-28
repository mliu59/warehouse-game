extends Node

func _ready() -> void:
	
	for i in range(1):
		var agent = load("res://scenes/elf.tscn").instantiate()
		$Agents.add_child(agent)
		agent.start_test_task(
			$Map.test_source + Vector2i(0, 1),
			$Map.test_target + Vector2i(-1, 0),
			$Map.spawn_point
		)
