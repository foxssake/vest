extends RefCounted
class_name VestCase

var description: String = ""
var callback: Callable

var definition_file: String = ""
var definition_line: int = -1

func _to_string() -> String:
	return "VestCase(\"%s\", \"%s\":%d)" % [description, definition_file, definition_line]

func _to_wire() -> Dictionary:
	return {
		"description": description,
		"definition_file": definition_file,
		"definition_line": definition_line
	}

static func _from_wire(data: Dictionary) -> VestCase:
	var result := VestCase.new()

	result.description = data["description"]
	result.definition_file = data["definition_file"]
	result.definition_line = data["definition_line"]

	return result
