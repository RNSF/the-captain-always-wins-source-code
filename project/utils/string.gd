class_name StringUtils
extends Object


static func make_string(item: Variant) -> String:
	return str(item)


static func strip_bbcode(source: String) -> String:
	var regex := RegEx.new()
	regex.compile("\\[.+?\\]")
	return regex.sub(source, "", true)
