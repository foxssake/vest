extends "res://addons/vest/runner/vest-base-runner.gd"
class_name VestLocalRunner

var _result_buffer: VestResult.Suite
var _is_running_glob := false

## Run a test script
func run_script(script: Script, only_mode: int = Vest.__.ONLY_DEFAULT) -> VestResult.Suite:
	if not script:
		return null

	var test_instance = script.new()
	if not test_instance is VestTest:
		test_instance.free()
		return null
	var test := test_instance as VestTest

	var suite = await test._get_suite()

	var run_only := false
	match only_mode:
		Vest.__.ONLY_DISABLED: run_only = false
		Vest.__.ONLY_AUTO: run_only = suite.has_only()
		Vest.__.ONLY_ENABLED: run_only = true

	var result := VestResult.Suite.new()
	if not _is_running_glob:
		_result_buffer = result
	else:
		result = _result_buffer

	await test._begin(test_instance)
	result = await _run_suite(result, suite, test, run_only)
	await test._finish(test)

	test.free()

	return result

## Run test scripts matching glob
## [br][br]
## See [method String.match]
func run_glob(glob: String, only_mode: int = Vest.__.ONLY_DEFAULT) -> VestResult.Suite:
	_is_running_glob = true
	_result_buffer = VestResult.Suite.new()
	_result_buffer.suite = VestDefs.Suite.new()
	_result_buffer.suite.name = "Glob suite \"%s\"" % [glob]

	for test_file in Vest.glob(glob):
		var suite_result := VestResult.Suite.new()
		_result_buffer.subsuites.append(suite_result)

		var result := await _run_suite_at(suite_result, test_file, only_mode)
		if not result:
			_result_buffer.subsuites.erase(suite_result)
	_is_running_glob = false

	return _result_buffer

# TODO: Refactor
func _run_suite_at(result: VestResult.Suite, path: String, only_mode: int = Vest.__.ONLY_DEFAULT) -> VestResult.Suite:
	var test_script := load(path)

	if not test_script or not test_script is Script:
		return null

	var test_instance = test_script.new()
	if not test_instance is VestTest:
		test_instance.free()
		return null
	var test := test_instance as VestTest

	var suite = await test._get_suite()

	var run_only := false
	match only_mode:
		Vest.__.ONLY_DISABLED: run_only = false
		Vest.__.ONLY_AUTO: run_only = suite.has_only()
		Vest.__.ONLY_ENABLED: run_only = true

	await test._begin(test_instance)
	result = await _run_suite(result, suite, test, run_only)
	await test._finish(test)

	test.free()

	return result

func _run_case(case: VestDefs.Case, test_instance: VestTest, run_only: bool, is_parent_only: bool = false) -> VestResult.Case:
	if run_only and not case.is_only and not is_parent_only:
		return null

	await test_instance._begin(case)
	await case.callback.call()
	await test_instance._finish(case)
	
	on_partial_result.emit(_result_buffer)

	return test_instance._get_result()

func _run_suite(result: VestResult.Suite, suite: VestDefs.Suite, test_instance: VestTest, run_only: bool, is_parent_only: bool = false) -> VestResult.Suite:
	if run_only and not suite.has_only() and not is_parent_only:
		return null

	result.suite = suite

	await test_instance._begin(suite)

	for subsuite in suite.suites:
		var suite_result := VestResult.Suite.new()
		suite_result = await _run_suite(suite_result, subsuite, test_instance, run_only, is_parent_only or suite.is_only)
		if suite_result != null:
			result.subsuites.append(suite_result)

	for case in suite.cases:
		var case_result := await _run_case(case, test_instance, run_only, is_parent_only or suite.is_only)
		if case_result != null:
			result.cases.append(case_result)

	await test_instance._finish(suite)

	return result
