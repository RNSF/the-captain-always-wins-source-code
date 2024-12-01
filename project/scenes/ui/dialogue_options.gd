class_name DialogueOptionsUI
extends Control

signal option_chosen(number: int)

const DialogueOptionUIScene = preload("res://scenes/ui/dialogue_option.tscn")
const DialogueOptionsSeparatorUIScene = preload("res://scenes/ui/dialogue_option_separator.tscn")

var dialogue_options : Array[DialogueOptionUI] = []
var dialogue_separators : Array[Control] = []
var visible_percentage := 0.0 :
	set(new_value):
		assert(new_value >= 0.0 and new_value <= 1.0)
		visible_percentage = new_value
		modulate.a = ceil(visible_percentage)
		visible = visible_percentage > 0

@onready var vbox : VBoxContainer = $VBoxContainer

func _ready() -> void:
	for i: int in range(Dialogue.MAX_OPTIONS):
		var dialogue_option : DialogueOptionUI = DialogueOptionUIScene.instantiate()
		dialogue_options.append(dialogue_option)
		var error := dialogue_option.selected.connect(func() -> void: option_chosen.emit(i))
		assert(not error)
		vbox.add_child(dialogue_option)
		
		if i < Dialogue.MAX_OPTIONS - 1:
			var dialogue_separator : Control = DialogueOptionsSeparatorUIScene.instantiate()
			dialogue_separators.append(dialogue_separator)
			vbox.add_child(dialogue_separator)


func load_options(options: Array, time_to_accept := 0.0) -> void:
	
	assert(options.size() <= Dialogue.MAX_OPTIONS)
	
	var hitbox_scale : Vector2 = [
		Vector2(1, 2),
		Vector2(1, 1.1),
		Vector2(1, 1.1),
	][options.size() - 1]
	
	vbox.add_theme_constant_override(&"separation", [
		0,
		2,
		1
	][options.size() - 1])
	
	for i in range(Dialogue.MAX_OPTIONS):
		var dialogue_option := dialogue_options[i]
		var dialogue_separator := dialogue_separators[i - 1]
		
		if i >= options.size():
			dialogue_option.hide()
			if dialogue_separator: 
				dialogue_separator.hide()
			continue
		
		var option_text : String = options[i]
		dialogue_option.call_deferred(&"show")
		if dialogue_separator: 
			dialogue_separator.show()
		dialogue_option.text = option_text
		dialogue_option.hitbox_scale = hitbox_scale
		dialogue_option.hitbox_offset = Vector2.ZERO
		dialogue_option.time_to_accept = time_to_accept
		
		if dialogue_option.text == "LIAR!": # hard coding this is gonna bite me in the ass later
			dialogue_option.time_to_accept = 0.5
			dialogue_option.shake_when_accepting = true
