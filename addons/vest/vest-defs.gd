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

class Benchmark:
	var callback: Callable
	var name: String = ""
	var iterations: int = 0
	var duration: float = 0.0

	var max_iterations: int = -1
	var max_duration: float = -1.0

	var _test: VestTest

	func with_iterations(p_iterations: int) -> Benchmark:
		max_iterations = p_iterations
		return self

	func with_duration(p_duration: float) -> Benchmark:
		max_duration = p_duration
		return self

	func once() -> Benchmark:
		max_iterations = 1
		max_duration = 0.0
		return run()

	func run() -> Benchmark:
		# Run benchmark
		while _is_within_limits():
			var t_start := Vest.time()
			callback.call()

			duration += Vest.time() - t_start
			iterations += 1

		# Report
		var result_data := _test._get_result().data
		var benchmarks := result_data.get("benchmarks", []) as Array
		benchmarks.append(_to_data())
		result_data["benchmarks"] = benchmarks

		# Set test to pass by default if no asserts are added
		_test.ok("", result_data)

		return self

	func _is_within_limits():
		if max_iterations >= 0 and iterations >= max_iterations:
			return false
		if max_duration >= 0.0 and duration >= max_duration:
			return false
		return true

	func _to_data() -> Dictionary:
		var result := {}
		result["name"] = name
		result["iterations"] = iterations
		result["duration"] = "%.4fms" % [duration * 1000.0]
		result["iters/sec"] = iterations / duration
		result["average iteration time"] = "%.4fms" % [duration / iterations * 1000.0]
		return result
