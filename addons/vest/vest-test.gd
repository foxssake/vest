extends Node
class_name VestTest

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
	_result.status = status
	_result.message = message
	_result.data = data

func _prepare_for_case():
	_result = VestResult.new()

func _get_result() -> VestResult:
	return _result

func _get_suite_name() -> String:
	# Check if callback is implemented
	if has_method("get_suite_name"):
		return call("get_suite_name")

	# Check if class_name is set
	var script := get_script() as Script
	var pattern := RegEx.create_from_string("class_name\\s+([^\n\\s]+)")
	var hit := pattern.search(script.source_code)

	if hit:
		return hit.get_string(1)

	# Fall back to script path
	return script.resource_path

func _get_suite() -> VestSuite:
	var suite := VestSuite.new()

	var script := get_script() as Script
	var inherited_methods := (script.get_base_script()
		.get_script_method_list()
		.map(func(it): return it["name"])
	)

	var methods := (script.get_script_method_list()
		.filter(func(it): return not it["name"].begins_with("_"))
		.filter(func(it): return not inherited_methods.has(it["name"]))
		)

	var define_methods := (methods
		.filter(func(it): return not it["return"]["class_name"].is_empty())
		.map(func(it): return it["name"])
	)

	var case_methods := (methods
		.filter(func(it): return not define_methods.has(it["name"]))
		.map(func(it): return it["name"])
	)

	return define(_get_suite_name(), func():
		for method in define_methods:
			call(method)

		for method in case_methods:
			test(method.capitalize(), func(): call(method))
	)
