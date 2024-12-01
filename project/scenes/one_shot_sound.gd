extends AudioStreamPlayer




func _ready() -> void:
	finished.connect(queue_free)
