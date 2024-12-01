@tool
extends Control

signal transition_requested

@onready var ear_ringing_sound := $EarRingingSound
@onready var label := $ColorRect/Label
@onready var animation_player := $AnimationPlayer
@onready var flash_white := $ColorRect

@export var ringing_loudness : float :
	set(new_value):
		ringing_loudness = clamp(new_value, 0.0, 1.0)
		ear_ringing_sound.volume_db = linear_to_db(ringing_loudness * 0.8)


@export var show_text := false
var in_transition := false
var is_active := false :
	set(new_value):
		if is_active == new_value: return
		is_active = new_value
		
		if not is_active:
			GameMaster.player_in_world = true
			in_transition = false
			flash_white.visible = false
			if animation_player:
				animation_player.stop()
				animation_player.play("RESET")




func _process(delta: float) -> void:
	if not is_active: return
	
	if show_text:
		label.visible_ratio += Subtitles.DEFAULT_SPEED * delta / label.text.length() * 0.5
	else:
		label.visible_ratio = 0.0
	
	if GameMaster.is_interact_just_pressed():
		if label.visible_ratio >= 1.0 and not animation_player.current_animation == "fade":
			animation_player.play("fade")
		elif show_text:
			label.visible_ratio = 1.0
	
	if animation_player.current_animation == "fade":
		ringing_loudness -= delta * 0.2


func _on_lightning_overlay_flashed() -> void:
	GameMaster.ambience.is_enabled = true
	is_active = false


func _on_liars_dice_physical_player_shot() -> void:
	is_active = true
	GameMaster.player_in_world = false
	GameMaster.ambience.is_enabled = false
	GameMaster.kill_lightning()
	in_transition = false
	
	label.text = "Let's try this again."
	if Progress.player_death_count > 0:
		label.text = "There must be a way to beat them."
	if Progress.player_death_count > 1:
		label.text = "Third times the charm."
	if Progress.player_death_count > 2:
		label.text = "One more try."
	if Progress.know_captain_secret:
		label.text = "I need to find a way out."
	if Progress.player_death_count_since_know_captain_secret > 0:
		label.text = "The other pirates may have useful info."
	if Progress.player_death_count_since_know_captain_secret > 1:
		label.text = "I'm so close to getting out."
	if Progress.player_death_count > 0 and not (Progress.know_captain_name and Progress.know_navy_name and Progress.know_pirate_name):
		label.text = "I should talk with the others more."
	
	Progress.player_death_count += 1
	if Progress.know_captain_secret:
		Progress.player_death_count_since_know_captain_secret += 1
	
	if animation_player:
		animation_player.stop()
		animation_player.play("shoot")


func _on_liars_dice_physical_navy_shot() -> void:
	if animation_player:
		animation_player.stop()
		animation_player.play("shoot_quick")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade":
		LiarsDice.start_new_life()
		transition_requested.emit()
