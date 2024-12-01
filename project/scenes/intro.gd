extends Node2D

signal finished

var is_dissolving := false
var dissolve_speed := 0.6
var slide_index := 0 :
	set(new_value):
		slide_index = clamp(new_value, 0, slides.size() - 1)
		
@export var is_active := true :
	set(new_value):
		is_active = new_value
		if not is_dissolving:
			visible = is_active
			camera.enabled = is_active
		if not is_node_ready(): await ready
		GameMaster.player_in_world = not is_active


@onready var dissolve_sound := $DissolveSound
@onready var camera := $Camera2D

@onready var slides : Array[IntroSlide] = [$Start, $Slide1, $Slide2, $Slide3, $Slide4]



func _ready() -> void:
	GameMaster.ambience.is_enabled = false
	is_active = not Debug.is_enabled
	for slide: IntroSlide in slides:
		slide.visible = true
		slides[slide_index].dissolve_percent = 1.0
	
	pass 
	
func dissolve() -> void:  
	is_dissolving = true
	if slide_index == slides.size() - 1:
		is_active = false
	dissolve_sound.play()
	match slide_index + 1:
		0: 
			GameMaster.ambience.is_enabled = false
		1: 
			GameMaster.ambience.ambience_level = 1
			GameMaster.ambience.is_enabled = true
			GameMaster.ambience.is_inside = false
		2: 
			GameMaster.ambience.is_hum_playing = true
		3: 
			GameMaster.ambience.is_creaking_wood_playing = true
		4: 
			GameMaster.ambience.is_inside = true
	
	
	
func _process(delta: float) -> void:
	
	if Debug.is_just_pressed(&"test_1"):
		is_active = true
	
	if ready_for_next_dissolve():
		if GameMaster.is_interact_just_pressed() and is_active:
			dissolve()
	
	if is_dissolving:
		get_current_slide().dissolve_percent  -= dissolve_speed * delta
		
		if get_current_slide().dissolve_percent <= 0.0:
			slides[slide_index].visible = false
			is_dissolving = false
			slide_index += 1
			if not is_active:
				visible = false
				camera.enabled = false
				Dialogue.play(DialogueInstance.Id.INTRO_DIALOGUE)
				finished.emit()


func get_current_slide() -> IntroSlide:
	return slides[slide_index]



func ready_for_next_dissolve() -> bool:
	return not is_dissolving and not dissolve_sound.playing and slide_index != 0


func _on_label_game_started() -> void:
	dissolve()
	pass # Replace with function body.
