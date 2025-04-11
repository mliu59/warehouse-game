extends Node


func map():					return get_node("/root/Main/Map")
func objMgr():				return get_node("/root/Main/Map/ObjectManager")
func taskMgr():				return get_node("/root/Main/TaskManager")
func agentMgr():			return get_node("/root/Main/AgentManager")

