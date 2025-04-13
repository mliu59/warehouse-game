extends Node


func map():					return get_node("/root/Main/Map")
func objMgr():				return get_node("/root/Main/Map/ObjectManager")
func taskMgr():				return get_node("/root/Main/TaskManager")
func agentMgr():			return get_node("/root/Main/AgentManager")
# func camera():				return get_node("/root/Main/MainCamera2D")
func mainCamera():			return get_tree().get_nodes_in_group("mainCamera")[0]

