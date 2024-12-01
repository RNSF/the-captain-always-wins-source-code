class_name LightningOverlay
extends Control

signal flashed

@onready var animation_player := $AnimationPlayer
@onready var flash_white := $Flash

func _ready() -> void:
	flash_white.visible = false
	GameMaster.lightning_overlay = self


func _process(delta: float) -> void:
	if Debug.is_just_pressed("test_6"):
		flash()


func flash() -> void:
	animation_player.stop()
	flash_white.visible = false
	animation_player.play(["lightning_1", "lightning_2", "lightning_3"].pick_random()) # i dont like  "lightning_4"


func stop() -> void:
	animation_player.stop()
	animation_player.play("RESET")


func _on_flash_visibility_changed() -> void:
	if not is_node_ready(): await ready
	if flash_white.visible:
		GameMaster.shake_camera_relative(0.3)
		flashed.emit()


func _on_gun_shot_overlay_transition_requested() -> void:
	flash()


func kill() -> void:
	animation_player.stop()
	animation_player.play("RESET")
