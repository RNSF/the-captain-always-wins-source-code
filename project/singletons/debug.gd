extends SettingsAbstract

var can_be_enabled := OS.is_debug_build()

#region Settings

var is_enabled := can_be_enabled :
	set(new_value):
		is_enabled = new_value and can_be_enabled
		print("Debug Mode: " + ("Enabled" if is_enabled else "Disabled"))
		queue_save_to_disk()

var start_scene_id : int :
	set(new_value):
		start_scene_id = new_value
		print("Set scene #" + str(start_scene_id) + " to debug start scene.")
		queue_save_to_disk()

var use_start_scene_id := false :
	set(new_value):
		use_start_scene_id = new_value
		print(("Enabled" if use_start_scene_id else "Disabled") + " debug start scene")
		queue_save_to_disk()

#endregion

func _ready() -> void:
	if not can_be_enabled:
		set_process(false)
		return
	
	DISK_PATH = "user://debug_settings.json"
	SETTINGS  = [
		&"is_enabled",
		&"start_scene_id",
		&"use_start_scene_id",
	]
	
	super._ready()
	
	if is_enabled and use_start_scene_id:
		SceneManager.scene_id = start_scene_id


func _process(delta: float) -> void:
	assert(Debug.can_be_enabled)
	
	if Input.is_action_just_pressed("debug_enable"):
		is_enabled = !is_enabled
	
	if is_enabled:
		if Input.is_action_just_pressed("debug_set_start_scene"):
			use_start_scene_id = true
			start_scene_id = SceneManager.scene_id
		if Input.is_action_just_pressed("debug_toggle_start_scene"):
			use_start_scene_id = !use_start_scene_id
		if Input.is_action_just_pressed("debug_quit_game"):
			get_tree().quit()
		if Input.is_action_just_pressed("debug_next_level"):
			SceneManager.goto_next_scene()
		if Input.is_action_just_pressed("debug_previous_level"):
			SceneManager.goto_previous_scene()
		if Input.is_action_just_pressed("debug_reset_level"):
			SceneManager.goto_current_scene()
	
	super._process(delta)


func is_just_pressed(control_name: StringName) -> bool:
	return is_enabled and Input.is_action_just_pressed(control_name)


func is_pressed(control_name: StringName) -> bool:
	return is_enabled and Input.is_action_pressed(control_name)


func is_just_released(control_name: StringName) -> bool:
	return is_enabled and Input.is_action_just_released(control_name)
