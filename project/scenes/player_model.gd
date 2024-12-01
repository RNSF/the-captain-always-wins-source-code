@tool
class_name PlayerModel
extends Node3D


@export var alive := true :
	set(new_value):
		if alive == new_value: return
		alive = new_value
		if alive:
			_revive()
		else:
			_kill()

var target_bob_speed := 0.05
var target_bob_amplitude := 0.05
var bob_speed : float = 1.0
var bob_amplitude := 0.05

@export var player : LiarsDice.Player :
	set(new_value):
		player = new_value
		if not is_node_ready(): await ready
		$Model/captainfinal.visible = player == LiarsDice.Player.CAPTAIN
		$Model/crewfatfinal.visible = player == LiarsDice.Player.PIRATE_RIGHT
		$Model/skinnycrew.visible = player == LiarsDice.Player.PIRATE_LEFT
@export var is_talking := false :
	set(new_value):
		is_talking = new_value
		target_bob_speed = 10.0 if is_talking else resting_animation_speed
		target_bob_amplitude = 0.04 if is_talking else 0.02

@export var turn_direction := 0

@onready var model := $Model
@onready var smoke_particles := $SmokeParticles
@onready var poof_sound := $Sounds/PoofSound

@onready var resting_animation_speed := randf_range(2.4, 2.6)
@onready var animation_time := randf() * TAU

func _ready() -> void:
	is_talking = false
	

func _process(delta: float) -> void:
	bob_speed = lerp(bob_speed, target_bob_speed, 5 * delta)
	bob_amplitude = lerp(bob_amplitude, target_bob_amplitude, 5 * delta)
	animation_time += delta * bob_speed
	
	model.rotation.y = lerp(model.rotation.y, float(turn_direction) * 0.3, delta * 5)
	
	var scale_offset = sin(animation_time)
	model.scale.y = lerp(1.0, 1.0 + bob_amplitude, scale_offset)
	model.scale.x = 1.0 / sqrt(model.scale.y)
	model.scale.z = 1.0 /  sqrt(model.scale.y)


func _revive():
	model.show()

func _kill():
	GameMaster.shake_camera(0.15)
	smoke_particles.restart()
	poof_sound.play()
	model.hide()
