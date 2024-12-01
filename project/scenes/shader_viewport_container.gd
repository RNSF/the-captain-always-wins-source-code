extends SubViewportContainer


func _ready() -> void:
	material.set_shader_parameter(&"u_color_tex", Palette.texture)
	Palette.texture_changed.connect(func(old_texture: Texture2D, new_texture: Texture2D) -> void: material.set_shader_parameter(&"u_color_tex", new_texture))
