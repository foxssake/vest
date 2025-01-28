extends Node
class_name VestTest

var _define_stack: Array[VestSuite] = []

func define(name: String, callback: Callable) -> VestSuite:
	var suite = VestSuite.new()
	suite.name = name
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
