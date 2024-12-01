class_name JSONUtils
extends Node


# Returns the json dictionary if successful, otherwise returns an empty dictionary
static func load_json(path: String) -> Dictionary:
	var data := {}
	
	if FileAccess.file_exists(path):
		var file := FileAccess.open(path, FileAccess.READ)
		if file:
			data = JSON.parse_string(file.get_as_text())
			file.close()
			file = null
	
	return data


# Returns true if successful
static func save_json(path: String, data: Dictionary) -> bool:
	var was_successful := false
	
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data))
		file.close()
		file = null
		was_successful = true
	
	return was_successful
