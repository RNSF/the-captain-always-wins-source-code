class_name Subtitles
extends Control

signal line_started
signal line_finished
signal line_continued

const DEFAULT_SPEED := 30.0
const FONT_SIZE := 12
const SIDE_BUFFER := 10

const PIRATE_LEFT_FONT = preload("res://fonts/rosalicious.ttf")
const PIRATE_RIGHT_FONT = preload("res://fonts/Alundraskinny.ttf")
const CAPTAIN_FONT = preload("res://fonts/OldWizard.ttf")

@export var font: Font :
	set(new_value):
		font = new_value
		if not is_node_ready():
			await ready
		label.add_theme_font_override(&"normal_font", font)

@onready var talk_1_sound : AudioStreamPlayer = $Sounds/Talk1
@onready var talk_2_sound : AudioStreamPlayer = $Sounds/Talk2
@onready var talk_3_sound : AudioStreamPlayer = $Sounds/Talk3

var regex : RegEx
var speed := DEFAULT_SPEED
var line : ParsedLine :
	set(new_value):
		line = new_value
		
		if line:
			label.text = line.text
		else:
			label.text = ""

var can_skip := true
var pause_time := 0.0
var char_index := 0.0 :
	set(new_value):
		var old_value := char_index
		char_index = new_value
		label.visible_characters = floor(max(char_index, 0.0))
		
		if line:
			label.size.x = font.get_string_size(line.bbcodeless_text.left(get_visible_character_count())).x + 4 # + 4 for outline
		
		if int(old_value) < int(char_index) and char_index < line.text.length() - 5:
			var talk_sound := get_talk_sound()
			talk_sound.pitch_scale = randf_range(0.9, 1.1)
			talk_sound.play()
		
		_update_position()


var target_x := 0.0 :
	set(new_value):
		target_x = new_value
		_update_position()


var current_speaker : Dialogue.Actor

@onready var label : RichTextLabel = $Label

func _ready() -> void:
	regex = RegEx.new()
	#regex.compile("(\\[set [_a-zA-Z]\\w*=[\\w\\.]+\\])|(\\[call [_a-zA-Z]\\w*])")
	var error := regex.compile("\\[.*?\\]")
	assert(not error)


func get_talk_sound(speaker := current_speaker) -> AudioStreamPlayer:
	match speaker:
		Dialogue.Actor.PIRATE_LEFT: return talk_2_sound
		Dialogue.Actor.PIRATE_RIGHT: return talk_3_sound
		Dialogue.Actor.CAPTAIN: return talk_1_sound
	return talk_1_sound


func init_new_line(new_speaker: Dialogue.Actor, unparsed_line: String) -> void:
	show()
	
	match new_speaker:
		Dialogue.Actor.PIRATE_LEFT: 	font = PIRATE_LEFT_FONT
		Dialogue.Actor.PIRATE_RIGHT: 	font = PIRATE_RIGHT_FONT
		Dialogue.Actor.CAPTAIN: 		font = CAPTAIN_FONT
	
	current_speaker = new_speaker
	speed = DEFAULT_SPEED
	char_index = -1.0
	line = parse_line("[center]" + Dialogue.get_actor_name(new_speaker) + ": " +  unparsed_line)
	LiarsDice.physical.player_models[Dialogue.get_liars_dice_player(current_speaker)].is_talking = true
	line_started.emit()

func parse_line(new_line: String) -> ParsedLine:
	var commands := {}
	
	
	var offset := 0
	var untrimmed_amount := 0
	while true:
		var regex_match := regex.search(new_line, offset)
		
		if not regex_match:
			break
		
		var letter_index := regex_match.get_start()
		offset = regex_match.get_end()
		
		
		
		
		var command : String = regex_match.get_string()
		command = command.rstrip("]").lstrip("[")
		
		var function_parts := command.split(" ")
		
		if function_parts.size() != 2:
			untrimmed_amount += regex_match.get_string().length()
			continue
		
		# trim
		new_line = new_line.erase(regex_match.get_start(), regex_match.get_string().length())
		offset = regex_match.get_start()
		
		var function_type := function_parts[0]
		
		
		var command_index := letter_index - untrimmed_amount
		if not command_index in commands:
			commands[command_index] = []
		
		match function_type:
			"set":
				var function_arguments := function_parts[1]
				var parts := function_arguments.split("=")
				var variable_name := parts[0]
				var value_name := parts[1]
				var current_variable_value : Variant = get(variable_name)
				var value : Variant = value_name
				
				if current_variable_value is String:
					pass
				elif current_variable_value is int:
					value = int(value_name)
				elif current_variable_value is float:
					value = float(value_name)
				else:
					push_error("Variable type is not supported in dialogue setter")
				
				commands[command_index].append(func() -> void: set(variable_name, value))
			"call":
				var method_name := function_parts[1]
				commands[command_index].append(func() -> void: call(method_name))
			"unskippable":
				can_skip = false
	
	var parsed_line := ParsedLine.new(new_line, commands)
	
	
	return parsed_line


func skip_to_end() -> void:
	char_index = INF
	LiarsDice.physical.player_models[Dialogue.get_liars_dice_player(current_speaker)].is_talking = false
	line_finished.emit()


func get_visible_character_count() -> int:
	if label.visible_characters < 0:
		return line.bbcodeless_text.length()
	else:
		return label.visible_characters

func _process(delta: float) -> void:
	if line:
		if not at_end_of_line():
			if can_skip and Input.is_action_just_pressed(&"interact") and GameMaster.player_in_world:
				skip_to_end()
			elif pause_time <= 0.0:
				talk(delta)
			else:
				pause_time = max(pause_time - delta, 0.0)
		else:
			if Input.is_action_just_pressed(&"interact") and GameMaster.player_in_world:
				line_continued.emit()
		
		 


func talk(delta: float) -> void:
	assert(not at_end_of_line())
	
	var old_char_i : int = floor(char_index)
	char_index += speed * delta
	var char_i : int = floor(char_index)
	
	for i in range(old_char_i + 1, char_i + 1):
		for command: Callable in line.commands.get(i, []):
			command.call()
	
	if at_end_of_line():
		LiarsDice.physical.player_models[Dialogue.get_liars_dice_player(current_speaker)].is_talking = false
		line_finished.emit()

func at_end_of_line() -> bool:
	return label.visible_ratio >= 1.0 or label.visible_characters <= -1


func _update_position() -> void:
	position.x = clamp(target_x - label.size.x / 2, SIDE_BUFFER, size.x - label.size.x - SIDE_BUFFER)
	#position.x = target_x - label.size.x / 2


func clear_line() -> void:
	hide()

class ParsedLine:
	var text := ""
	var bbcodeless_text := ""
	var commands := {}
	
	func _init(p_text: String, p_commands: Dictionary) -> void:
		text = p_text
		bbcodeless_text = StringUtils.strip_bbcode(text)
		commands = p_commands
