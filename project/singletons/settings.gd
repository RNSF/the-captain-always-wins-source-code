extends SettingsAbstract




#region Settings

var is_in_fullscreen := true : 
	set(new_value):
		if is_in_fullscreen == new_value: return
		is_in_fullscreen = new_value
		_update_window()

var is_fullscreen_exclusive := true :
	set(new_value):
		if is_fullscreen_exclusive == new_value: return
		is_fullscreen_exclusive = is_fullscreen_exclusive
		_update_window()

var is_window_maximized := false :
	set(new_value):
		if is_window_maximized == new_value: return
		is_window_maximized = new_value
		_update_window()

var is_music_muted := false :
	set(new_value):
		is_music_muted = new_value
		AudioServer.set_bus_mute(AudioServer.get_bus_index(&"Music"), is_music_muted)
		queue_save_to_disk()

var are_sfx_muted := false :
	set(new_value):
		are_sfx_muted = new_value
		AudioServer.set_bus_mute(AudioServer.get_bus_index(&"SFX"), are_sfx_muted)
		queue_save_to_disk()



#endregion

func _ready() -> void:
	DISK_PATH = "user://settings.json"
	SETTINGS  = [
		&"is_in_fullscreen",
		&"is_fullscreen_exclusive",
		&"is_window_maximized",
		&"is_music_muted",
		&"are_sfx_muted",
	]
	
	
	super._ready()
	
	_update_window()


func _process(delta: float) -> void:
	if Input.is_action_just_pressed(&"toggle_fullscreen"):
		is_in_fullscreen = !is_in_fullscreen
	if DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_WINDOWED:
		is_window_maximized = false
	if DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_MAXIMIZED:
		is_window_maximized = true
	if DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN:
		is_in_fullscreen = true
		is_fullscreen_exclusive = true
	if DisplayServer.window_get_mode(0) == DisplayServer.WINDOW_MODE_FULLSCREEN:
		is_in_fullscreen = true
		is_fullscreen_exclusive = false
	
	
	super._process(delta)


func _update_window() -> void:
	queue_save_to_disk()
	if is_in_fullscreen:
		if is_fullscreen_exclusive:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		if is_window_maximized:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
