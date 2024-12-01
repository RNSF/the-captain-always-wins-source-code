class_name DialogueOptionUI
extends Control

signal selected

@export var time_to_accept := 0.0
@export var text := "" : 
	set(new_value):
		text = new_value
		label.fancy_text = text
@export var hitbox_scale := Vector2.ONE
@export var hitbox_offset := Vector2.ZERO
@export var shake_when_accepting := false

var hold_time := 0.0 :
	set(new_value):
		var old_value := hold_time
		hold_time = clamp(new_value, 0, time_to_accept)
		if old_value == hold_time: return
		label.charge_percentage = get_hold_percentage()
		if old_value < time_to_accept and hold_time >= time_to_accept:
			GameMaster.shake_camera_relative(0.2)
			accuse_sound.play()
			selected.emit()
		
		if hold_time == 0.0:
			suspense_sound.stop()
		else:
			suspense_sound.volume_db = linear_to_db(lerp(0.4, 0.7, get_hold_percentage()))
			suspense_sound.pitch_scale = lerp(0.5, 1.0, get_hold_percentage())
			if hold_time > old_value: GameMaster.shake_camera_relative(get_hold_percentage() * 0.05)
			if not suspense_sound.playing: suspense_sound.play(randf_range(0.0, 2.0))
		
var is_hovered := false :
	set(new_value):
		var old_value = is_hovered
		is_hovered = new_value
		label.material.set_shader_parameter(&"text_color", Color.WHITE if is_hovered else Color.GRAY)
		if old_value == new_value: return
		if visible and is_hovered:
			hover_sound.pitch_scale = randf_range(0.9, 1.1) * 0.33
			hover_sound.play()
		

@onready var label : Label = $Offset/Label
@onready var offset : Control = $Offset
@onready var suspense_sound : AudioStreamPlayer = $Sounds/Suspense
@onready var accuse_sound : AudioStreamPlayer = $Sounds/Accuse
@onready var hover_sound : AudioStreamPlayer = $Sounds/Hover
@onready var select_sound : AudioStreamPlayer = $Sounds/Select

func _process(delta: float) -> void:
	var rect := get_global_rect()
	rect.position += hitbox_offset - (hitbox_scale - Vector2.ONE) * rect.size / 2
	rect.size *= hitbox_scale
	
	is_hovered = rect.has_point(get_viewport_rect().get_center() / 2)
	
	var is_accepting := false
	if visible and is_hovered:
		if time_to_accept == 0.0 and GameMaster.is_interact_just_pressed() and GameMaster.player_in_world:
			select_sound.play()
			selected.emit()
		elif get_hold_percentage() < 1.0 and Input.is_action_pressed("interact") and GameMaster.player_in_world:
			hold_time += delta
			is_accepting = true
		else:
			hold_time = 0.0
	else:
		hold_time = 0.0
	
	if is_accepting and shake_when_accepting:
		offset.position = Vector2(randf_range(-1, 1), randf_range(-1, 1))
	else:
		offset.position = Vector2.ZERO


func get_hold_percentage() -> float:
	if time_to_accept == 0.0:
		return 0.0
	return hold_time / time_to_accept
