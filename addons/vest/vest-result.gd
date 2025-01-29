extends RefCounted
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
	var suite: VestSuite
	var cases: Array[Case] = []
	var subsuites: Array[Suite] = []

	func get_aggregate_status() -> int:
		var result := TEST_PASS
		if not cases.is_empty():
			result = mini(result, cases.map(func(it): return it.status).min())
		if not subsuites.is_empty():
			result = mini(result, subsuites.map(func(it): return it.get_aggregate_status()).min())
		return result

	func get_count_by_status(p_status: int) -> int:
		return (
			cases.filter(func(it): return it.status == p_status).size() +
			subsuites.filter(func(it): return it.get_aggregate_status() == p_status).size()
		)

	func _to_wire() -> Dictionary:
		return {
			"suite": suite._to_wire(),
			"cases": cases.map(func(it): return it._to_wire()),
			"subsuites": subsuites.map(func(it): return it._to_wire())
		}

	static func _from_wire(data: Dictionary) -> Suite:
		var result := Suite.new()

		result.suite = VestSuite._from_wire(data["suite"])
		result.cases.assign(data["cases"].map(func(it): return Case._from_wire(it)))
		result.subsuites.assign(data["subsuites"].map(func(it): return Suite._from_wire(it)))

		return result

class Case:
	var case: VestCase

	var status: int = TEST_VOID
	var message: String = ""
	var data: Dictionary = {}

	# TODO: Support assert locations
	var assert_file: String = ""
	var assert_line: int = -1

	func _to_string() -> String:
		return "VestResult(status=%s, message=\"%s\", data=%s, assert_loc=\"%s\":%d)" % [
			VestResult.get_status_string(status), message, data, assert_file, assert_line
		]

	func _to_wire() -> Dictionary:
		return {
			"case": case._to_wire(),
			"status": status,
			"message": message,
			"data": data
		}

	static func _from_wire(data: Dictionary) -> Case:
		var result := Case.new()

		result.case = VestCase._from_wire(data["case"])
		result.status = data["status"]
		result.message = data["message"]
		result.data = data["data"]

		return result

static func get_status_string(p_status: int) -> String:
	match p_status:
		TEST_VOID: return "VOID"
		TEST_TODO: return "TODO"
		TEST_FAIL: return "FAIL"
		TEST_SKIP: return "SKIP"
		TEST_PASS: return "PASS"
		_: return "?"
