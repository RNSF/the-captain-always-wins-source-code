extends Node

signal interact_pressed

var camera_shaker : CameraShakeManager
var player_in_world := true
var straight_camera : Camera3D
var lightning_overlay : LightningOverlay
var ambience : Ambience
var mouse_in_window := true

func shake_camera(shake_amount: float) -> void:
	if camera_shaker:
		camera_shaker.shake(shake_amount)


func shake_camera_relative(shake_amount: float) -> void:
	if camera_shaker:
		camera_shaker.shake_relative(shake_amount)


func flash_lightning() -> void:
	if lightning_overlay:
		lightning_overlay.flash()


func kill_lightning() -> void:
	if lightning_overlay:
		lightning_overlay.stop()

func free_object(obj: Object) -> void:
	obj.free()



func _notification(blah):
	match blah:
		NOTIFICATION_WM_MOUSE_EXIT:
			mouse_in_window = false
		NOTIFICATION_WM_MOUSE_ENTER:
			mouse_in_window = true


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("escape") and Input.MOUSE_MODE_CAPTURED:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Input.is_action_just_pressed("interact") and mouse_in_window:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func is_interact_just_pressed() -> bool:
	return Input.mouse_mode == Input.MOUSE_MODE_CAPTURED and Input.is_action_just_pressed("interact")

func is_interact_pressed() -> bool:
	return Input.mouse_mode ==  Input.MOUSE_MODE_CAPTURED and Input.is_action_pressed("interact")
