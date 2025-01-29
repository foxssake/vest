extends Node
class_name VestRunner

class RunResult:
	var suite: VestSuite
	var case: VestCase
	var result: VestResult

	static func of(p_suite: VestSuite, p_case: VestCase, p_result: VestResult) -> RunResult:
		var result := RunResult.new()
		result.suite = p_suite
		result.case = p_case
		result.result = p_result

		return result

	func _to_string() -> String:
		return "RunResult(suite=%s, case=%s, result=%s)" % [suite.name, case, result]

func run_case(suite: VestSuite, case: VestCase) -> VestResult.Case:
	var test_instance := suite._owner
	test_instance._prepare_for_case(case)

	case.callback.call()
	return test_instance._get_result()

func run_suite(suite: VestSuite) -> VestResult.Suite:
	var result := VestResult.Suite.new()
	result.suite = suite

	for subsuite in suite.suites:
		result.subsuites.append(run_suite(subsuite))

	for case in suite.cases:
		result.cases.append(run_case(suite, case))

	return result

func run_instance(instance: VestTest) -> VestResult.Suite:
	return run_suite(instance._get_suite())
