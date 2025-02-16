extends "res://addons/vest/runner/vest-base-runner.gd"
class_name VestLocalRunner

func run_case(case: VestDefs.Case, test_instance: VestTest) -> VestResult.Case:
	test_instance._begin(case)
	case.callback.call()
	test_instance._finish(case)

	return test_instance._get_result()

func run_suite(suite: VestDefs.Suite, test_instance: VestTest) -> VestResult.Suite:
	var result := VestResult.Suite.new()
	result.suite = suite

	test_instance._begin(suite)

	for subsuite in suite.suites:
		result.subsuites.append(run_suite(subsuite, test_instance))

	for case in suite.cases:
		result.cases.append(run_case(case, test_instance))

	test_instance._finish(suite)

	return result

func run_script(script: Script) -> VestResult.Suite:
	if not script:
		return null

	var test_instance = script.new()

	var results: VestResult.Suite = null
	if test_instance is VestTest:
		test_instance._begin(test_instance)
		results = run_suite(test_instance._get_suite(), test_instance)
		test_instance._finish(test_instance)
	test_instance.free()

	return results

func run_glob(glob: String) -> VestResult.Suite:
	var result := VestResult.Suite.new()
	result.suite = VestDefs.Suite.new()
	result.suite.name = "Glob suite \"%s\"" % [glob]

	for test_file in _glob(glob):
		var suite_result := run_script_at(test_file)
		if suite_result:
			result.subsuites.append(suite_result)

	return result

func _get_time() -> float:
	return Time.get_ticks_msec() / 1000.
