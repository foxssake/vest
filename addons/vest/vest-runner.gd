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

func run_case(suite: VestSuite, case: VestCase) -> RunResult:
	var test_instance := suite._owner
	test_instance._prepare_for_case()

	case.callback.call()
	var result := test_instance._get_result()

	return RunResult.of(suite, case, result)

func run_suite(suite: VestSuite) -> Array[RunResult]:
	var results: Array[RunResult] = []

	for subsuite in suite.suites:
		results.append_array(run_suite(subsuite))

	for case in suite.cases:
		results.append(run_case(suite, case))

	return results

func run_instance(instance: VestTest) -> Array[RunResult]:
	return run_suite(instance._get_suite())
