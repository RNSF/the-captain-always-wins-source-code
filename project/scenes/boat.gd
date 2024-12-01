@tool
extends Node2D

@onready var sprite := $Sprite

func _process(delta: float) -> void:
	sprite.position.y = sin(Time.get_ticks_msec() / 700.0) * 6
