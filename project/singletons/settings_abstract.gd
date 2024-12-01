class_name SettingsAbstract
extends Node

var DISK_PATH := ""
var SETTINGS : Array[StringName] = []

var is_save_to_disk_queued := false


func _ready() -> void:
	assert(DISK_PATH != "")
	for setting_name in SETTINGS:
		assert(get(setting_name) != null)
	load_from_disk()


func _process(delta: float) -> void:
	if is_save_to_disk_queued:
		save_to_disk()

#region Saving to Disk

func load_from_disk() -> void:
	var settings_on_disk := JSONUtils.load_json(DISK_PATH)
	
	for setting_name: StringName in SETTINGS:
		if setting_name in settings_on_disk:
			set(setting_name, settings_on_disk.get(setting_name))
		else:
			push_warning("Setting value not found on disk for " + setting_name + ". Using default value.")


func queue_save_to_disk() -> void:
	is_save_to_disk_queued = true


func save_to_disk() -> void:
	is_save_to_disk_queued = false
	
	var json := {}
	
	for setting_name: StringName in SETTINGS:
		json[setting_name] = get(setting_name)
	
	var was_successful := JSONUtils.save_json(DISK_PATH, json)
	
	if not was_successful:
		push_warning("Failed to save settings to disk!")

#endregion
