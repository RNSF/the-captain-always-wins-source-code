@tool
extends Node2D



func _process(delta: float) -> void:
	rotation = sin(Time.get_ticks_msec() / 500.0) * 0.015
