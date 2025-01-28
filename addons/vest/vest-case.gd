extends RefCounted
class_name VestCase

var description: String = ""
var callback: Callable

# TODO: Support definition locations
var definition_file: String = ""
var definition_line: int = -1

func _to_string() -> String:
	return "VestCase(\"%s\", \"%s\":%d)" % [description, definition_file, definition_line]
