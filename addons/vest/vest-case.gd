extends RefCounted
class_name VestCase

var description: String = ""
var callback: Callable

var definition_file: String = ""
var definition_line: int = -1

func _to_string() -> String:
	return "VestCase(\"%s\")" % description
