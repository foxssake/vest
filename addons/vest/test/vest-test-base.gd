extends Object

var _define_stack: Array[VestDefs.Suite] = []
var _result: VestResult.Case

signal on_suite_begin(suite: VestDefs.Suite)
signal on_case_begin(case: VestDefs.Case)
signal on_any_begin()
signal on_any_finish()
signal on_case_finish(case: VestDefs.Case)
signal on_suite_finish(case: VestDefs.Case)

func define(name: String, callback: Callable) -> VestDefs.Suite:
	var suite = VestDefs.Suite.new()
	suite.name = name
	_define_stack.push_back(suite)

	var userland_loc := _find_userland_stack_location()
	suite.definition_file = userland_loc[0]
	suite.definition_line = userland_loc[1]

	callback.call()

	_define_stack.pop_back()
	if not _define_stack.is_empty():
		_define_stack.back().suites.push_back(suite)

	return suite

func test(description: String, callback: Callable) -> void:
	var case_def := VestDefs.Case.new()
	case_def.description = description
	case_def.callback = callback

	var userland_loc := _find_userland_stack_location()
	case_def.definition_file = userland_loc[0]
	case_def.definition_line = userland_loc[1]

	_define_stack.back().cases.push_back(case_def)

func todo(message: String = "", data: Dictionary = {}) -> void:
	_with_result(VestResult.TEST_TODO, message, data)

func skip(message: String = "", data: Dictionary = {}) -> void:
	_with_result(VestResult.TEST_SKIP, message, data)

func fail(message: String = "", data: Dictionary = {}) -> void:
	_with_result(VestResult.TEST_FAIL, message, data)

func ok(message: String = "", data: Dictionary = {}) -> void:
	_with_result(VestResult.TEST_PASS, message, data)

func before_suite(_suite_def: VestDefs.Suite):
	pass

func before_case(_case_def: VestDefs.Case):
	pass

func before_each():
	pass

func after_each():
	pass

func after_case(_case_def: VestDefs.Case):
	pass

func after_suite(_suite_def: VestDefs.Suite):
	pass

func _init():
	pass

func _with_result(status: int, message: String, data: Dictionary):
	if _result.status != VestResult.TEST_VOID and status == VestResult.TEST_PASS:
		# Test already failed, don't override with PASS
		return

	_result.status = status
	_result.message = message
	_result.data = data

	var userland_loc := _find_userland_stack_location()
	_result.assert_file = userland_loc[0]
	_result.assert_line = userland_loc[1]

func _begin(what: Object):
	if what is VestDefs.Suite:
		on_suite_begin.emit(what)
		before_suite(what)
	elif what is VestDefs.Case:
		_prepare_for_case(what)

		on_any_begin.emit()
		on_case_begin.emit(what)

		before_each()
		before_case(what)
	else:
		push_error("Beginning unknown object: %s" % [what])

func _finish(what: Object):
	if what is VestDefs.Suite:
		on_suite_finish.emit(what)
		after_suite(what)
	elif what is VestDefs.Case:
		on_any_finish.emit()
		on_case_finish.emit(what)

		after_each()
		after_case(what)
	else:
		push_error("Finishing unknown object: %s" % [what])

func _prepare_for_case(case_def: VestDefs.Case):
	_result = VestResult.Case.new()
	_result.case = case_def

func _get_result() -> VestResult.Case:
	return _result

func _get_suite() -> VestDefs.Suite:
	return define("OVERRIDE ME", func():)

func _find_userland_stack_location() -> Array:
	var stack := get_stack()
	if stack.is_empty():
		return [(get_script() as Script).resource_path, -1]

	var trimmed_stack := stack.filter(func(it): return not it["source"].begins_with("res://addons/vest"))
	if trimmed_stack.is_empty():
		return ["<unknown>", -1]
	else:
		return [trimmed_stack[0]["source"], trimmed_stack[0]["line"]]

# --------------------------------------------------------------------------------------------------

func measure(name: String, callback: Callable) -> Measurement:
	var result := Measurement.new()
	result.name = name
	result.callback = callback
	result._test = self
	return result

class Measurement:
	var callback: Callable
	var name: String = ""
	var iterations: int = 0
	var duration: float = 0.0

	var max_iterations: int = -1
	var max_duration: float = -1.0

	var _test: VestTest

	func with_iterations(p_iterations: int) -> Measurement:
		max_iterations = p_iterations
		return self

	func with_duration(p_duration: float) -> Measurement:
		max_duration = p_duration
		return self

	func once() -> Measurement:
		max_iterations = 1
		max_duration = 0.0
		return run()

	func run() -> Measurement:
		# Run benchmark
		while is_within_limits():
			var t_start := Vest.time()
			callback.call()

			duration += Vest.time() - t_start
			iterations += 1

		# Report
		var result_data := _test._get_result().data
		var benchmarks := result_data.get("benchmarks", []) as Array
		benchmarks.append(to_data())
		result_data["benchmarks"] = benchmarks

		# Set test to pass by default if no asserts are added
		_test.ok("", result_data)

		return self

	func is_within_limits():
		if max_iterations >= 0 and iterations > max_iterations:
			return false
		if max_duration >= 0.0 and duration > max_duration:
			return false
		return true

	func to_data() -> Dictionary:
		var result := {}
		result["name"] = name
		result["iterations"] = iterations
		result["duration"] = "%.4fms" % [duration * 1000.0]
		result["iters/sec"] = iterations / duration
		result["average iteration time"] = "%.4fms" % [duration / iterations * 1000.0]
		return result
