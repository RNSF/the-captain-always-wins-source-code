extends Object
class_name CSVUtils


# The first line of the csv are keys of the dictionary
# Returns a (dictionary of a (dictionary for each line))
static func load_to_json(path: String, parse_functions := {}) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	var result := {}
	
	if file:
		var headers = file.get_csv_line()
		
		while true:
			var line := file.get_csv_line()
			
			if file.eof_reached():
				break
			
			var identifier := StringName(line[0])
			var line_result := {}
			var i := 0
			for item: String in line:
				var parse_function : Callable = parse_functions.get(headers[i], StringUtils.make_string)
				var item_result : Variant = parse_function.call(item)
				line_result[headers[i]] = item_result
				i += 1
			
			result[identifier] = line_result
		
		file.close()
	return result
