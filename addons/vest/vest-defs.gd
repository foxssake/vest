extends Object
class_name VestDefs

class Suite:
	var name: String = ""
	var cases: Array[VestDefs.Case] = []
	var suites: Array[VestDefs.Suite] = []

	var definition_file: String = ""
	var definition_line: int = -1

	func size() -> int:
		return cases.size() + suites.reduce(func(acc, it): return acc + it.size(), 0)

	func _to_string() -> String:
		return "VestDefs.Suite(name=\"%s\", cases=%s, suites=%s)" % [name, cases, suites]

	func _to_wire() -> Dictionary:
		return { "name": name }

	static func _from_wire(data: Dictionary) -> Suite:
		var result := Suite.new()
		result.name = data["name"]
		return result

class Case:
	var description: String = ""
	var callback: Callable

	var definition_file: String = ""
	var definition_line: int = -1

	func _to_string() -> String:
		return "VestDefs.Case(\"%s\", \"%s\":%d)" % [description, definition_file, definition_line]

	func _to_wire() -> Dictionary:
		return {
			"description": description,
			"definition_file": definition_file,
			"definition_line": definition_line
		}

	static func _from_wire(data: Dictionary) -> Case:
		var result := Case.new()

		result.description = data["description"]
		result.definition_file = data["definition_file"]
		result.definition_line = data["definition_line"]

		return result
