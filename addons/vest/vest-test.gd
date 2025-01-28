extends Node
class_name VestTest

var _defined_suite: VestSuite

func define(name: String, callback: Callable) -> VestSuite:
	if _defined_suite:
		# TODO: Support nested defines
		push_error("Already defining a suite!")
		return

	_defined_suite = VestSuite.new()
	_defined_suite.name = name

	callback.call()

	var result = _defined_suite
	_defined_suite = null

	return result

func test(description: String, callback: Callable) -> void:
	var case := VestCase.new()
	case.description = description
	case.callback = callback

	_defined_suite.cases.push_back(case)
