class_name VestResult

# Result enums
enum {
	TEST_VOID,
	TEST_TODO,
	TEST_FAIL,
	TEST_SKIP,
	TEST_PASS
}

class Suite:
	var suite: VestDefs.Suite
	var cases: Array[Case] = []
	var benchmarks: Array[Benchmark] = []
	var subsuites: Array[Suite] = []

	func size() -> int:
		return cases.size() + benchmarks.size() + subsuites.reduce(func(acc, it): return acc + it.size(), 0)

	func get_aggregate_status() -> int:
		var result: int = TEST_PASS
		if not cases.is_empty():
			result = mini(result, cases.map(func(it): return it.status).min())
		if not subsuites.is_empty():
			result = mini(result, subsuites.map(func(it): return it.get_aggregate_status()).min())
		return result

	func get_aggregate_status_string() -> String:
		return VestResult.get_status_string(get_aggregate_status())

	func get_count_by_status(p_status: int) -> int:
		return (
			cases.filter(func(it): return it.status == p_status).size() +
			subsuites.filter(func(it): return it.get_aggregate_status() == p_status).size()
		)

	func _to_wire() -> Dictionary:
		return {
			"suite": suite._to_wire(),
			"cases": cases.map(func(it): return it._to_wire()),
			"benchmarks": benchmarks.map(func(it): return it._to_wire()),
			"subsuites": subsuites.map(func(it): return it._to_wire())
		}

	static func _from_wire(data: Dictionary) -> Suite:
		var result := Suite.new()

		result.suite = VestDefs.Suite._from_wire(data["suite"])
		result.cases.assign(data["cases"].map(func(it): return Case._from_wire(it)))
		result.benchmarks.assign(data["benchmarks"].map(func(it): return Benchmark._from_wire(it)))
		result.subsuites.assign(data["subsuites"].map(func(it): return Suite._from_wire(it)))

		return result

class Case:
	var case: VestDefs.Case

	var status: int = TEST_VOID
	var message: String = ""
	var data: Dictionary = {}

	var assert_file: String = ""
	var assert_line: int = -1

	func get_status_string() -> String:
		return VestResult.get_status_string(status)

	func _to_wire() -> Dictionary:
		return {
			"case": case._to_wire(),
			"status": status,
			"message": message,
			"data": data,
			"assert_file": assert_file,
			"assert_line": assert_line
		}

	static func _from_wire(p_data: Dictionary) -> Case:
		var result := Case.new()

		result.case = VestDefs.Case._from_wire(p_data["case"])
		result.status = p_data["status"]
		result.message = p_data["message"]
		result.data = p_data["data"]
		result.assert_file = p_data["assert_file"]
		result.assert_line = p_data["assert_line"]

		return result

class Benchmark:
	var benchmark: VestDefs.Benchmark

	var duration: float = 0.
	var iterations: int = 0

	func _to_wire() -> Dictionary:
		return {
			"benchmark": benchmark._to_wire(),
			"duration": duration,
			"iterations": iterations
		}

	static func _from_wire(data: Dictionary) -> Benchmark:
		var result := Benchmark.new()

		result.benchmark = VestDefs.Benchmark._from_wire(data["benchmark"])
		result.duration = data["duration"]
		result.iterations = data["iterations"]

		return result

static func get_status_string(p_status: int) -> String:
	match p_status:
		TEST_VOID: return "VOID"
		TEST_TODO: return "TODO"
		TEST_FAIL: return "FAIL"
		TEST_SKIP: return "SKIP"
		TEST_PASS: return "PASS"
		_: return "?"
