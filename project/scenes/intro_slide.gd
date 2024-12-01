@tool
class_name IntroSlide
extends CanvasGroup




@export var dissolve_texture : Texture2D :
	set(new_value):
		dissolve_texture = new_value
		material.set_shader_parameter("dissolve_texture", dissolve_texture)

@export var dissolve_percent := 1.0 :
	set(new_value):
		dissolve_percent = clamp(new_value, 0.0, 1.0)
		material.set_shader_parameter("dissolve_value", dissolve_percent)
