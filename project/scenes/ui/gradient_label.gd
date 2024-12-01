@tool
class_name GradientLabel
extends Label



@export var font : Font :
	set(new_value):
		font = new_value
		if not is_node_ready():
			await ready
		add_theme_font_override(&"font", font)
@export var fancy_text: String = "my_text":
	set(new_value):
		fancy_text = new_value
		text = fancy_text
		_update_shader()
@export var charge_percentage := 0.0 :
	set(new_value):
		charge_percentage = clamp(new_value, 0.0, 1.0)
		material.set_shader_parameter(&"charge_percent", charge_percentage)

func _on_item_rect_changed() -> void:
	_update_shader()


func _update_shader() -> void:
	var real_width := font.get_string_size(text).x
	material.set_shader_parameter(&"width", real_width)
	material.set_shader_parameter(&"offset_x", (size.x - real_width) / 2 - 1)
