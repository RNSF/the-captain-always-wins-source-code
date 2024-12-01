class_name PlayerCamera
extends Node3D

signal state_transition_completed(old_state: State, new_state: State)

const ZOOMED_FOV = 25.0
const SENSITIVITY = Vector2(0.0015, 0.0015)
const PAN_SPEED = 3.0

enum State {
	IN_GAME,
	AT_REVEAL,
}

@onready var detector : RayCast3D = $Detector
@onready var camera : Camera3D = $Camera
@onready var shake_manager : CameraShakeManager = $ShakeManager

var tween : Tween :
	set(new_value):
		if tween:
			tween.stop()
		tween = new_value
var transition_percent := 0.0 :
	set(new_value):
		transition_percent = clamp(new_value, 0.0, 1.0)
		if transition_percent >= 1.0:
			var old := old_state
			old_state = state
			transition_percent = 0.0
			state_transition_completed.emit(old, state)
var is_active := false :
	set(new_value):
		is_active = new_value
		camera.current = is_active

var is_panning := false

var pan_target := Vector2.ZERO :
	set(new_value):
		if new_value == pan_target: return
		pan_target = new_value.clamp(Vector2.ZERO, Vector2.ONE)
		is_panning = true

var current_cup : Cup :
	set(new_value):
		if current_cup == new_value: return
		if current_cup:	current_cup.target_raised = false
		current_cup = new_value
		if current_cup:	current_cup.target_raised = true
		if current_cup and LiarsDice.round and LiarsDice.round.get_current_player() == LiarsDice.Player.SELF:
			Progress.has_player_looked_at_cup = true

var current_ui : GuiPanel :
	set(new_value):
		if current_ui == new_value: return
		if current_ui:
			current_ui.update_mouse_position(Vector3.ZERO, false)
		current_ui = new_value


var current_gun : Gun :
	set(new_value):
		if current_gun == new_value: return
		if current_gun: current_gun.is_hovered = false
		current_gun = new_value
		if current_gun: current_gun.is_hovered = true

var mouse_position := Vector2(0.5, 0.3):
	set(new_value):
		mouse_position = new_value
		mouse_position = mouse_position.clamp(Vector2.ZERO, Vector2.ONE)

@onready var state_points := {} # keys are State: values are Node3D

var state := State.IN_GAME
var old_state := state

func _ready() -> void:
	is_active = true
	
	for camera_point: CameraPoint in get_tree().get_nodes_in_group(&"CameraPoints"):
		assert(not state_points.has(camera_point.type))
		state_points[camera_point.type] = camera_point
	
	for required_state: State in State.size():
		if not state_points.has(required_state): push_warning("Missing camera state point for state " + str(required_state))
	
	GameMaster.straight_camera = $StraightCamera



func pan_to_point(world_position: Vector3) -> void:
	var displacement := (world_position - global_position)
	
	var horizontal_angle := Vector2(-displacement.z, displacement.x).angle()
	var vertical_angle := Vector2(Vector2(displacement.x, displacement.z).length(), displacement.y).angle()
	
	pan_target = Vector2(
		inverse_lerp(-get_max_rotation_sideways(), get_max_rotation_sideways(), horizontal_angle),
		inverse_lerp(get_max_rotation_up(), -get_max_rotation_down(), vertical_angle)
	)
	


func _unhandled_input(event: InputEvent) -> void:
	if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return
	if event is InputEventMouseMotion and GameMaster.player_in_world and not is_panning:
		mouse_position += event.relative * SENSITIVITY

func _process(delta: float) -> void:
	
	if is_panning:
		mouse_position = mouse_position.lerp(pan_target, delta * PAN_SPEED)
		if mouse_position.distance_to(pan_target) < 0.01:
			is_panning = false
	
	var is_colliding := detector.is_colliding()
	var new_cup : Cup = null
	var new_ui : GuiPanel = null
	var new_gun : Gun = null
	if is_colliding:
		var mask : int = detector.get_collider().collision_layer
		if mask & CollisionLayer.ZOOM:
			var collider := detector.get_collider()
			new_cup = collider.cup if collider else null
		if mask & CollisionLayer.UI:
			var collider := detector.get_collider()
			new_ui = collider.gui_panel
			new_ui.update_mouse_position(detector.get_collision_point())
		if mask & CollisionLayer.GUN:
			var collider := detector.get_collider()
			new_gun = collider.get_parent()
	
	# update zoom
	current_cup = new_cup
	current_ui = new_ui
	current_gun = new_gun
	
	camera.fov = lerp(camera.fov, ZOOMED_FOV if current_cup or state == State.AT_REVEAL else get_normal_fov(), 10.0 * delta)
	camera.rotation = shake_manager.get_shake_rotation(delta)
	
	## UPDATE ROTATION
	var end_rotation := Vector3(
		ease_camera(mouse_position.y, get_max_rotation_up(), -get_max_rotation_down(), 0.2),
		ease_camera(mouse_position.x, get_max_rotation_sideways(), -get_max_rotation_sideways(), 1.0),
		0
	)
	
	var start_rotation := Vector3(
		ease_camera(mouse_position.y, get_max_rotation_up(old_state), -get_max_rotation_down(old_state), 0.2),
		ease_camera(mouse_position.x, get_max_rotation_sideways(old_state), -get_max_rotation_sideways(old_state), 1.0),
		0
	)
	
	rotation = start_rotation.lerp(end_rotation, transition_percent)
	
	## UPDATE POSITION
	var end_position : Vector3 = state_points.get(state).global_position if state_points.has(state) else global_position
	var start_position : Vector3 = state_points.get(old_state).global_position if state_points.has(old_state) else global_position
	global_position = start_position.lerp(end_position, transition_percent)
	
	
	if current_gun and current_gun.can_pickup and GameMaster.is_interact_just_pressed():
		current_gun.state = Gun.State.WITH_PLAYER


func get_normal_fov() -> float:
	if not LiarsDice.round: 				return 62.0
	if LiarsDice.alive_players.size() >= 4:	return 57.0
	if LiarsDice.alive_players.size() >= 3:	return 52.0
	return 52.0


func get_max_rotation_up(for_state := state) -> float:
	match(for_state):
		State.IN_GAME: 		return 0.2
		State.AT_REVEAL: 	return -0.8
	return 0.0


func get_max_rotation_sideways(for_state := state) -> float:
	match(for_state):
		State.IN_GAME: 		return 0.6
		State.AT_REVEAL: 	return 0.1
	return 0.0


func get_max_rotation_down(for_state := state) -> float:
	match(for_state):
		State.IN_GAME: 		return 0.85
		State.AT_REVEAL: 	return 0.9
	return 0.0


func transition_state(new_state: State) -> void:
	if new_state == state: return
	old_state = state
	state = new_state
	tween = get_tree().create_tween()
	tween.tween_property(self, "transition_percent", 1.0, 1.0).from(0.0).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_EXPO)
	tween.play()



func ease_camera(x: float, min_value: float, max_value: float, intensity: float) -> float:
	assert(x >= 0.0 and x <= 1.0)
	# see https://www.desmos.com/calculator/fpg0lbelf2
	return 1/atan(intensity) * (max_value - min_value) / 2 * atan(2 * intensity * (x-0.5)) + (max_value + min_value) / 2
	
