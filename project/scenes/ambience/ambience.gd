@tool

class_name Ambience
extends Node




@export var is_creaking_wood_playing := false :
	set(new_value):
		is_creaking_wood_playing = new_value
		if not is_node_ready(): await ready
		$ShipWood.playing = is_creaking_wood_playing

@export var is_hum_playing := false :
	set(new_value):
		is_hum_playing = new_value

@export var hum_loudness : float = 1.0
@export var static_loudness : float = 0.0

@export var is_inside := false :
	set(new_value):
		is_inside = new_value
		if not is_node_ready(): await ready
		AudioServer.set_bus_effect_enabled(AudioServer.get_bus_index("Outside"), 0, is_inside)
		$JungleNight.playing = not is_inside

@export var is_enabled := false :
	set(new_value):
		is_enabled = new_value
		if not is_node_ready(): await ready
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Ambience"), not is_enabled)

@export var ambience_level := 1 :
	set(new_value):
		ambience_level = clamp(new_value, 1, 3)
		
		match ambience_level:
			1:
				$Hum.pitch_scale = 1.0
				hum_loudness = 0.3
				static_loudness = 0.0
				pass
			2:
				hum_loudness = 0.4
				$Hum.pitch_scale = 0.95
				static_loudness = 0.3
				pass
			3:
				hum_loudness = 0.5
				$Hum.pitch_scale = 0.9
				static_loudness = 0.6
				pass


func _ready() -> void:
	if not Engine.is_editor_hint(): GameMaster.ambience = self
	is_enabled = false
	is_inside = false
	is_hum_playing = false
	static_loudness = 0.0
	$Waves.playing = true
	$Storm.playing = true
	$Hum.playing = true
	$Static.playing = true
	$Hum.volume_db = linear_to_db(0.0)
	$Static.volume_db = linear_to_db(0.0)


func _process(delta: float) -> void:
	$Hum.volume_db = linear_to_db(lerp(db_to_linear($Hum.volume_db), float(is_hum_playing) * hum_loudness, delta * 1))
	$Static.volume_db = linear_to_db(lerp(db_to_linear($Static.volume_db), float(is_hum_playing) * static_loudness, delta * 1))
