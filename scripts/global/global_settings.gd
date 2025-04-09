extends Node

var global_settings: Dictionary = {
	"debug": true,

}

func get_setting(_name: String) -> Variant:
	if global_settings.has(_name):
		return global_settings[_name]
	return null


