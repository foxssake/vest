extends Node

var _define_stack: Array[VestDefs.Suite] = []
var _result: VestResult.Case
var _bail: bool = false

signal on_suite_begin(suite: VestDefs.Suite)
signal on_case_begin(case: VestDefs.Case)
signal on_benchmark_begin(benchmark: VestDefs.Benchmark)
signal on_any_begin()
signal on_any_finish()
signal on_benchmark_finish(benchmark: VestDefs.Benchmark)
signal on_case_finish(case: VestDefs.Case)
signal on_suite_finish(case: VestDefs.Case)

func define(name: String, callback: Callable) -> VestDefs.Suite:
	var suite = VestDefs.Suite.new()
	suite.name = name
	suite._owner = self
	_define_stack.push_back(suite)

	callback.call()

	_define_stack.pop_back()
	if not _define_stack.is_empty():
		_define_stack.back().suites.push_back(suite)

	return suite

func test(description: String, callback: Callable) -> void:
	var case := VestDefs.Case.new()
	case.description = description
	case.callback = callback

	var userland_loc := _find_userland_stack_location()
	case.definition_file = userland_loc[0]
	case.definition_line = userland_loc[1]

	_define_stack.back().cases.push_back(case)

func benchmark(description: String, callback: Callable) -> VestDefs.Benchmark:
	var benchmark := VestDefs.Benchmark.new()
	benchmark.description = description
	benchmark.callback = callback

	var userland_loc := _find_userland_stack_location()
	benchmark.definition_file = userland_loc[0]
	benchmark.definition_line = userland_loc[1]

	_define_stack.back().benchmarks.push_back(benchmark)

	return benchmark

func bail() -> void:
	_bail = true

func todo(message: String = "", data: Dictionary = {}):
	_with_result(VestResult.TEST_TODO, message, data)

func skip(message: String = "", data: Dictionary = {}):
	_with_result(VestResult.TEST_SKIP, message, data)

func fail(message: String = "", data: Dictionary = {}):
	_with_result(VestResult.TEST_FAIL, message, data)

func ok(message: String = "", data: Dictionary = {}):
	_with_result(VestResult.TEST_PASS, message, data)

func before_suite(suite: VestDefs.Suite):
	pass

func before_case(case: VestDefs.Case):
	pass

func before_benchmark(benchmark: VestDefs.Benchmark):
	pass

func before_each():
	pass

func after_each():
	pass

func after_benchmark(benchmark: VestDefs.Benchmark):
	pass

func after_case(case: VestDefs.Case):
	pass

func after_suite(suite: VestDefs.Suite):
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
	elif what is VestDefs.Benchmark:
		_prepare_for_benchmark(what)

		on_any_begin.emit()
		on_benchmark_begin.emit(what)

		before_each()
		before_benchmark(what)
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
	elif what is VestDefs.Benchmark:
		on_any_finish.emit()
		on_benchmark_finish.emit(what)

		after_each()
		after_benchmark(what)
	else:
		push_error("Finishing unknown object: %s" % [what])

func _prepare_for_case(case: VestDefs.Case):
	_result = VestResult.Case.new()
	_result.case = case

func _prepare_for_benchmark(benchmark: VestDefs.Benchmark):
	_bail = false

func _is_bailing() -> bool:
	return _bail

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
