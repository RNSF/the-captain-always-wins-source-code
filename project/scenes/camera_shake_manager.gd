class_name CameraShakeManager
extends Node

@export var max_shake: Vector3 = Vector3(5.0, 5.0, 1.0)
@onready var noise := FastNoiseLite.new()

var amount: float = 0.0
var shake_reduction: float = 0.6
var shake_time: float = 0.0
var noise_speed: float = 800.0


func _enter_tree() -> void:
	GameMaster.camera_shaker = self


func _exit_tree() -> void:
	if GameMaster.camera_shaker == self:
		GameMaster.camera_shaker = null

func shake(shake_amount: float) -> void:
	amount = clamp(amount + shake_amount, 0.0, 1.0)


func shake_relative(shake_amount: float) -> void:
	amount = max(amount, clamp(shake_amount, 0.0, 1.0))


func get_shake_intensity() -> float:
	return amount * amount
	
	
func get_noise(_seed: int) -> float:
	noise.seed = _seed
	return noise.get_noise_1d(shake_time * noise_speed)
	
	
func get_shake_rotation(delta: float) -> Vector3:
	var rotation_offset := Vector3.ZERO
	shake_time += delta
	amount = max(amount - shake_reduction*delta, 0.0)
	rotation_offset.x = max_shake.x * get_shake_intensity() * get_noise(0)
	rotation_offset.y = max_shake.y * get_shake_intensity() * get_noise(1)
	rotation_offset.z = max_shake.z * get_shake_intensity() * get_noise(2)
	return rotation_offset
