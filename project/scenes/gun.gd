@tool
class_name Gun
extends Node3D

signal picked_up

const OUTLINE_MATERIAL = preload("res://scenes/outline_material.tres")

enum State {
	ON_TABLE,
	WITH_PLAYER,
	UNDRAWN,
	DRAWN,
}

@export var can_pickup := false :
	set(new_value):
		can_pickup = new_value and state == State.ON_TABLE
		if not is_node_ready(): await ready
		hurtbox.collision_layer = CollisionLayer.GUN if can_pickup else CollisionLayer.NONE
@export var state : State :
	set(new_value):
		if state == new_value: return
		state = new_value
		is_clamped = false
		can_pickup = can_pickup
		if state == State.WITH_PLAYER: picked_up.emit()
@export var pirate : Dialogue.Actor :
	set(new_value):
		pirate = new_value
		if is_node_ready(): regenerate_state_points()
@export var simulate_in_editor := false

@export var is_outline_enabled := false :
	set(new_value):
		is_outline_enabled = new_value
		for material: ShaderMaterial in materials:
			material.set_shader_parameter("outline_width", 4 if is_outline_enabled else 0)

@onready var hurtbox := $Hurtbox
@onready var state_points := []
@onready var model := $Model

var is_clamped := false
var is_hovered := false :
	set(new_value):
		is_hovered = new_value
		is_outline_enabled = is_hovered
var materials : Array[ShaderMaterial] = []



func _ready() -> void:
	regenerate_state_points()
	
	if not Engine.is_editor_hint():
		for node: Node in model.find_children("*"):
			if not node is MeshInstance3D: continue
			var model := node as MeshInstance3D
			model.mesh = model.mesh.duplicate(true)
			for i: int in model.mesh.get_surface_count():
				var material := model.mesh.surface_get_material(i)
				var shader_material := OUTLINE_MATERIAL.duplicate()
				shader_material.set_shader_parameter("outline_color", Color.WHITE)
				shader_material.set_shader_parameter("outline_width", 0)
				model.mesh.surface_set_material(i, shader_material)
				shader_material.next_pass = material
				materials.append(shader_material)


func regenerate_state_points() -> void:
	state_points = get_tree().get_nodes_in_group(&"GunPoints").filter(func(gun_point: GunPoint) -> bool: return gun_point.pirate == pirate)
	state_points.sort_custom(func(a: GunPoint, b: GunPoint) -> bool: return a.state < b.state)
	
	for i: int in State.size():
		if state_points.size() <= i or state_points[i].state != i:
			state_points.insert(i, null)

func _process(delta: float) -> void:
	if Engine.is_editor_hint() and not simulate_in_editor: return
	
	if not Engine.is_editor_hint() and Debug.is_just_pressed("test_5") and pirate == Dialogue.Actor.PIRATE_LEFT:
		state = State.ON_TABLE
		can_pickup = true
	
	var target_scale : Vector3 = Vector3.ONE  * (1.2 if is_hovered and can_pickup else 1)
	scale = scale.lerp(target_scale, delta * 10)
	if state < state_points.size():
		var gun_point : GunPoint = state_points[state]
		
		if gun_point:
			if is_clamped:
				global_position = gun_point.global_position
				global_rotation = gun_point.global_rotation
			else:
				global_position = global_position.lerp(gun_point.global_position, 6 * delta)
				global_rotation = Quaternion.from_euler(global_rotation).slerp(Quaternion.from_euler(gun_point.global_rotation), 6 * delta).get_euler()
				if global_position.distance_to(gun_point.global_position) < 0.001:
					is_clamped = true
	
