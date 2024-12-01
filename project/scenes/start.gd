extends Node

func _ready() -> void:
	SceneManager.call_deferred("goto_start_scene")
