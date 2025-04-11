extends Node2D

func _ready() -> void:
	visible = GlobalSettings.get_setting("debug")
