extends Node

var _define_stack: Array[VestSuite] = []
var _result: VestResult

func define(name: String, callback: Callable) -> VestSuite:
	var suite = VestSuite.new()
	suite.name = name
	suite._owner = self
	_define_stack.push_back(suite)

	callback.call()

	_define_stack.pop_back()
	if not _define_stack.is_empty():
		_define_stack.back().suites.push_back(suite)

	return suite

func test(description: String, callback: Callable) -> void:
	var case := VestCase.new()
	case.description = description
	case.callback = callback

	_define_stack.back().cases.push_back(case)

func todo(message: String = "", data: Dictionary = {}):
	_with_result(VestResult.TEST_TODO, message, data)

func skip(message: String = "", data: Dictionary = {}):
	_with_result(VestResult.TEST_SKIP, message, data)

func fail(message: String = "", data: Dictionary = {}):
	_with_result(VestResult.TEST_FAIL, message, data)

func ok(message: String = "", data: Dictionary = {}):
	_with_result(VestResult.TEST_PASS, message, data)

func _with_result(status: int, message: String, data: Dictionary):
	if _result.status != VestResult.TEST_VOID and status == VestResult.TEST_PASS:
		# Test already failed, don't override with PASS
		return

	_result.status = status
	_result.message = message
	_result.data = data

func _prepare_for_case():
	_result = VestResult.new()

func _get_result() -> VestResult:
	return _result

func _get_suite() -> VestSuite:
	return define("OVERRIDE ME", func():)
