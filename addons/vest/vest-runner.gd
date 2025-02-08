extends Node
class_name VestRunner

func run_case(suite: VestDefs.Suite, case: VestDefs.Case) -> VestResult.Case:
	var test_instance := suite._owner

	test_instance._begin(case)
	case.callback.call()
	test_instance._finish(case)

	return test_instance._get_result()

func run_benchmark(suite: VestDefs.Suite, benchmark: VestDefs.Benchmark) -> VestResult.Benchmark:
	var result := VestResult.Benchmark.new()
	var test_instance := suite._owner

	result.benchmark = benchmark

	if not benchmark.is_valid():
		return result

	test_instance._begin(benchmark)

	while true:
		var t_start := _get_time()
		benchmark.callback.call()
		var t_finish := _get_time()

		result.iterations += 1
		result.duration += t_finish - t_start

		if (benchmark.max_iterations > 0 and result.iterations >= benchmark.max_iterations) or \
			(benchmark.timeout > 0.) and (result.duration >= benchmark.timeout) or \
			test_instance._is_bailing():
				break

	test_instance._finish(benchmark)

	return result

func run_suite(suite: VestDefs.Suite) -> VestResult.Suite:
	var test_instance := suite._owner
	var result := VestResult.Suite.new()
	result.suite = suite

	test_instance._begin(suite)

	for subsuite in suite.suites:
		result.subsuites.append(run_suite(subsuite))

	for case in suite.cases:
		result.cases.append(run_case(suite, case))

	for benchmark in suite.benchmarks:
		result.benchmarks.append(run_benchmark(suite, benchmark))

	test_instance._finish(suite)

	return result

func run_instance(instance: VestTest) -> VestResult.Suite:
	return run_suite(instance._get_suite())

func run_script_at(path: String) -> VestResult.Suite:
	var test_script := load(path)

	if not test_script or not test_script is Script:
		return null

	var test_instance = test_script.new()
	if not test_instance is VestTest:
		return null

	return run_instance(test_instance)

func run_instance_in_background(instance: VestTest) -> VestResult.Suite:
	var host := VestDaemonHost.new()
	add_child(host)

	var result := await host.run_instance(instance)
	host.queue_free()

	return result

func run_script_in_background(script: Script) -> VestResult.Suite:
	var host := VestDaemonHost.new()
	add_child(host)

	var result := await host.run_script(script)
	host.queue_free()

	return result

func _get_time() -> float:
	return Time.get_ticks_msec() / 1000.
