class_name GuiPanel
extends Node3D


# Used for checking if the mouse is inside the Area3D.
var is_mouse_inside := false :
	set(new_value):
		is_mouse_inside = new_value
		better.block_mouse_input = not is_mouse_inside
		if not is_mouse_inside:
			node_viewport.push_input(InputEventMouseMotion.new())
# The last processed input touch/mouse event. To calculate relative movement.
var last_mouse_position : Variant = null
# The time of the last event in seconds since engine start.
var last_event_time: float = -1.0

var mouse_position := Vector2.ZERO

@onready var node_viewport := $SubViewport
@onready var node_quad := $Quad
@onready var node_area := $Quad/Area3D
@onready var better := $SubViewport/Better



func _unhandled_input(event: InputEvent) -> void:
	if not Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: return
	# Check if the event is a non-mouse/non-touch event
	if is_mouse_inside:
		for mouse_event: Variant in [InputEventMouseButton, InputEventScreenTouch]:
			if is_instance_of(event, mouse_event):
				# If the event is a mouse/touch event, then we can ignore it here, because it will be
				# handled via Physics Picking.
				handle_input_event(event)
				break
		node_viewport.push_input(event)



func _process(delta: float) -> void:
	if is_mouse_inside:
		handle_input_event(InputEventMouseMotion.new())


func update_mouse_position(event_position: Vector3, in_region := true) -> void:
	is_mouse_inside = in_region
	if not is_mouse_inside: return
	
	var quad_mesh_size : Vector2 = node_quad.mesh.size
	event_position = node_quad.global_transform.affine_inverse() * event_position
	var event_position_2d := Vector2(event_position.x, -event_position.y)
	var percent_position := (event_position_2d / quad_mesh_size + Vector2.ONE / 2)
	mouse_position = percent_position * Vector2(node_viewport.size)


func handle_input_event(event: InputEvent) -> void:
	assert(is_mouse_inside)
	
	event.position = mouse_position
	if event is InputEventMouse:
		event.global_position = mouse_position
	
	# Current time in seconds since engine start.
	var now: float = Time.get_ticks_msec() / 1000.0
	
	# Calculate the relative event distance.
	if event is InputEventMouseMotion or event is InputEventScreenDrag:
		# If there is not a stored previous position, then we'll assume there is no relative motion.
		if last_mouse_position == null:
			event.relative = Vector2(0, 0)
		# If there is a stored previous position, then we'll calculate the relative position by subtracting
		# the previous position from the new position. This will give us the distance the event traveled from prev_pos.
		else:
			event.relative = mouse_position - last_mouse_position
			event.velocity = event.relative / (now - last_event_time)
	
	# Update last_mouse_position with the position we just calculated.
	last_mouse_position = mouse_position

	# Update last_event_time to current time.
	last_event_time = now

	# Finally, send the processed input event to the viewport.
	node_viewport.push_input(event)


func rotate_area_to_billboard() -> void:
	var billboard_mode : int = node_quad.get_surface_override_material(0).params_billboard_mode

	# Try to match the area with the material's billboard setting, if enabled.
	if billboard_mode > 0:
		# Get the camera.
		var camera := get_viewport().get_camera_3d()
		# Look in the same direction as the camera.
		var look := camera.to_global(Vector3(0, 0, -100)) - camera.global_transform.origin
		look = node_area.position + look

		# Y-Billboard: Lock Y rotation, but gives bad results if the camera is tilted.
		if billboard_mode == 2:
			look = Vector3(look.x, 0, look.z)

		node_area.look_at(look, Vector3.UP)

		# Rotate in the Z axis to compensate camera tilt.
		node_area.rotate_object_local(Vector3.BACK, camera.rotation.z)


func find_mouse() -> Variant:
	var camera := get_viewport().get_camera_3d()
	
	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	
	var ray_parameters := PhysicsRayQueryParameters3D.new()
	ray_parameters.from = camera.global_position
	var distance := 5
	ray_parameters.to = ray_parameters.from + Quaternion.from_euler(camera.rotation) * Vector3.RIGHT * distance
	ray_parameters.collision_mask = 2
	ray_parameters.collide_with_bodies = false
	ray_parameters.collide_with_areas = true
	
	var result = space_state.intersect_ray(ray_parameters)
	if result.size() > 0:
		return result.position
	else:
		return null
