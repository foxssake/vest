extends Object
class_name VestDefs

class Suite:
	var name: String = ""
	var cases: Array[VestDefs.Case] = []
	var benchmarks: Array[VestDefs.Benchmark] = []
	var suites: Array[VestDefs.Suite] = []

	var definition_file: String = ""
	var definition_line: int = -1

	func size() -> int:
		return cases.size() + benchmarks.size() + suites.size()

	func _to_string() -> String:
		return "VestDefs.Suite(name=\"%s\", cases=%s, benchmarks=%s suites=%s)" % [name, cases, benchmarks, suites]

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

class Benchmark:
	var description: String = ""
	var callback: Callable

	var definition_file: String = ""
	var definition_line: int = -1

	var max_iterations: int = -1
	var timeout: float = -1.

	func is_valid() -> bool:
		return max_iterations > 0 or timeout > 0.

	func with_iterations(p_iterations: int) -> Benchmark:
		max_iterations = p_iterations
		return self

	func with_timeout(p_timeout: float) -> Benchmark:
		timeout = p_timeout
		return self

	func _to_string():
		return "VestDefs.Benchmark(\"%s\", \"%s\":%d)" % [description, definition_file, definition_line]

	func _to_wire() -> Dictionary:
		return {
			"description": description,
			"definition_file": definition_file,
			"definition_line": definition_line,
			"max_iterations": max_iterations,
			"timeout": timeout
		}

	static func _from_wire(data: Dictionary) -> Benchmark:
		var result := Benchmark.new()

		result.description = data["description"]
		result.definition_file = data["definition_file"]
		result.definition_line = data["definition_line"]
		result.max_iterations = data["max_iterations"]
		result.timeout = data["timeout"]

		return result
