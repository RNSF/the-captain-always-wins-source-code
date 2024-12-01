class_name DieTextureRect
extends TextureRect


@export var faces : Array[Texture2D] = []


var face : int = 1 :
	set(new_value):
		face = clamp(new_value, 1, faces.size())
		texture = faces[face - 1]
