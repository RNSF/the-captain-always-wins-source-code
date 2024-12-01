extends Sprite3D

@onready var viewport : SubViewport = $SubViewport

func _unhandled_input(event: InputEvent):
	var is_mouse_event := false
	if event is InputEventMouseMotion or event is InputEventMouseButton:
		is_mouse_event = true
		
	if is_mouse_event:
		handle_mouse(event)
	elif not is_mouse_event:
		viewport.push_input(event,true)


func handle_mouse(event: InputEvent):
	var size : Vector2 = Vector2(viewport.size) * Vector2(scale.x, scale.y)
	
	#if event is InputEventMouseButton or event is InputEventScreenTouch:
		#mouse_held = event.pressed
	
	var mouse_position_3d = find_mouse(event.global_position)
	
	mouse_inside = mouse_position_3d != null
	
	if mouse_inside:
		mouse_position_3d = area.global_transform.affine_inverse() * mouse_position_3d
		last_mouse_pos_3D = mouse_position_3d
	else:
		mouse_position_3d = last_mouse_pos_3D
		if mouse_position_3d == null:
			mouse_position_3d = Vector3.ZERO
	var mouse_position_2d = Vector2(mouse_position_3d.x, -mouse_position_3d.y)
	
	#convert from -meshsize/2 to meshsize/2
	mouse_position_2d.x += size.x / 2
	mouse_position_2d.y += size.y / 2
	#convert to 0 to 1
	mouse_position_2d.x = mouse_position_2d.x / size.x
	mouse_position_2d.y = mouse_position_2d.y / size.y
	#convert to viewport range 0 to veiwport size
	mouse_position_2d.x = mouse_position_2d.x * viewport.size.x
	mouse_position_2d.y = mouse_position_2d.y * viewport.size.y
	
	event.position = mouse_position_2d
	event.global_position = mouse_position_2d
	
	if event is InputEventMouseMotion:
		if last_mouse_pos_2D == null:
			event.relative = Vector2(0,0)
		else:
			event.relative = mouse_position_2d - last_mouse_pos_2D
		
	last_mouse_pos_2D = mouse_position_2d
	
	viewport.push_input(event)
