@tool
extends Button



@export var texture_offset := Vector2.ZERO :
	set(new_value):
		if texture_offset == new_value: return
		texture_offset = new_value
		_update_texture_position()

@export var normal_texture : Texture2D
@export var pressed_texture : Texture2D
@export var hovered_texture : Texture2D
@export var disabled_texture : Texture2D

var current_texture : Texture2D = null :
	set(new_value):
		if current_texture == new_value: return
		current_texture = new_value
		texture_rect.size = current_texture.get_size() if current_texture else Vector2.ZERO
		texture_rect.texture = current_texture
		_update_texture_position()

@onready var texture_rect := $TextureRect


func _ready() -> void:
	_update_texture_position()


func _process(delta: float) -> void:
	if disabled:
		current_texture = disabled_texture
	elif button_pressed:
		current_texture = pressed_texture
	elif is_hovered():
		current_texture = hovered_texture
	else:
		current_texture = normal_texture


func _update_texture_position():
	if not is_node_ready(): await ready
	texture_rect.position = (size - texture_rect.size) / 2 + texture_offset


func _on_item_rect_changed() -> void:
	_update_texture_position()
