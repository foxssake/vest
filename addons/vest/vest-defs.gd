extends Object
class_name VestDefs

## Grouping class for test definition primitives.
##
## See [VestDefs.Suite][br]
## See [VestDefs.Case][br]
## See [VestDefs.Benchmark][br]

## Test suite definition.
##
## A test suite consists of test cases, and optionally other, nested test
## suites.
##
## @tutorial(Writing tests): https://foxssake.github.io/vest/latest/user-guide/writing-tests/
class Suite:
	## Test suite name, displayed in reports
	var name: String = ""

	## Test cases contained in the suite
	var cases: Array[VestDefs.Case] = []

	## Nested test suites contained in the suite
	var suites: Array[VestDefs.Suite] = []

	## The resource path to the script that defined the suite
	var definition_file: String = ""

	## The line number of the suite definition. [br]
	## Set to -1 for undetermined.
	var definition_line: int = -1

	## Get the number of test cases in the suite.[br]
	## Includes the number of test cases in the suite, and recursively sums up
	## the test cases in any of the nested suites.
	func size() -> int:
		return cases.size() + suites.reduce(func(acc, it): return acc + it.size(), 0)

	func _to_string() -> String:
		return "VestDefs.Suite(name=\"%s\", cases=%s, suites=%s)" % [name, cases, suites]

	func _to_wire() -> Dictionary:
		return { "name": name }

	static func _from_wire(data: Dictionary) -> Suite:
		var result := Suite.new()
		result.name = data["name"]
		return result

## Test case definition.
##
## @tutorial(Writing tests): https://foxssake.github.io/vest/latest/user-guide/writing-tests/
class Case:
	## Test case description, displayed in reports
	var description: String = ""

	## The method called to run the test case
	var callback: Callable

	## The resource path to the script that defined the suite
	var definition_file: String = ""

	## The line number of the suite definition.[br]
	## Set to -1 for undetermined.
	var definition_line: int = -1

	func _to_string() -> String:
		return "VestDefs.Case(\"%s\", \"%s\":%d)" % [description, definition_file, definition_line]

	func _to_wire() -> Dictionary:
		return {
			"description": description,
			"definition_file": definition_file,
			"definition_line": definition_line
		}

	static func _from_wire(data: Dictionary) -> Case:
		var result := Case.new()

		result.description = data["description"]
		result.definition_file = data["definition_file"]
		result.definition_line = data["definition_line"]

		return result

## Benchmark definition.
##
## Benchmarks run a piece of code multiple times, measuring how much time each
## iteration took.
##
## @tutorial(Benchmarking): https://foxssake.github.io/vest/latest/user-guide/benchmarking/
class Benchmark:
	## Method to measure during the benchmark
	var callback: Callable

	## Benchmark name, displayed in the reports
	var name: String = ""

	var _iterations: int = 0
	var _duration: float = 0.0

	var _max_iterations: int = -1
	var _max_duration: float = -1.0
	var _enable_builtin_measures: bool = true

	var _measures: Array[VestMetrics.Measure] = []
	var _metric_signals: Dictionary = {} # metric name to signal

	signal _on_emit_template(value: Variant)

	var _test: VestTest

	## Set a limit on the number of iterations to run.
	func with_iterations(p_iterations: int) -> Benchmark:
		_max_iterations = p_iterations
		return self

	## Set a limit on the duration for running the benchmark.
	## [br][br]
	## The duration limit is in [i]seconds[/i].
	func with_duration(p_duration: float) -> Benchmark:
		_max_duration = p_duration
		return self

	func with_measure(measure: VestMetrics.Measure) -> Benchmark:
		# Append measure
		_measures.append(measure)

		# Connect to appropriate signal
		var metric := measure.get_metric_name()
		if not _metric_signals.has(metric):
			_metric_signals[metric] = Signal(_on_emit_template)
		(_metric_signals[metric] as Signal).connect(measure.ingest)

		return self

	func measure_value(metric: StringName) -> Benchmark:
		with_measure(VestMetrics.LastValueMeasure.new(metric))
		return self

	func measure_average(metric: StringName) -> Benchmark:
		with_measure(VestMetrics.AverageMeasure.new(metric))
		return self

	func measure_max(metric: StringName) -> Benchmark:
		with_measure(VestMetrics.MaxMeasure.new(metric))
		return self

	func measure_min(metric: StringName) -> Benchmark:
		with_measure(VestMetrics.MinMeasure.new(metric))
		return self

	func measure_sum(metric: StringName) -> Benchmark:
		with_measure(VestMetrics.SumMeasure.new(metric))
		return self

	func without_builtin_measures() -> Benchmark:
		_enable_builtin_measures = false
		return self

	## Run the benchmark only once.
	func once() -> Benchmark:
		_max_iterations = 1
		_max_duration = 1.0
		return run()

	## Run the benchmark with the configured limits.
	func run() -> Benchmark:
		# Run benchmark
		while _is_within_limits():
			var t_start := Vest.time()
			callback.call(_emit)

			_duration += Vest.time() - t_start
			_iterations += 1

		# Report
		var result_data := _test._get_result().data
		var benchmarks := result_data.get("benchmarks", []) as Array
		benchmarks.append(_to_data())
		result_data["benchmarks"] = benchmarks

		# Set test to pass by default if no asserts are added
		_test.ok("", result_data)

		return self

	## Get the number of iterations ran.
	func get_iterations() -> int:
		return _iterations

	## Get the total time it took to run the benchmark.
	func get_duration() -> float:
		return _duration

	## Get the average number of iterations ran per second.
	func get_iters_per_sec() -> float:
		return _iterations / _duration

	## Get the average time it took to run an iteration, in seconds.
	func get_avg_iteration_time() -> float:
		return _duration / _iterations

	func get_measurement(metric: StringName, measurement: StringName) -> Variant:
		for measure in _measures:
			if measure.get_metric_name() == metric and measure.get_measure_name() == measurement:
				return measure.get_value()

		assert(false, "Measurement not found!")
		return null

	func _is_within_limits():
		if _max_iterations >= 0 and _iterations >= _max_iterations:
			return false
		if _max_duration >= 0.0 and _duration >= _max_duration:
			return false
		return true

	func _emit(metric: StringName, value: Variant) -> void:
		assert(_metric_signals.has(metric), "Trying to emit a metric that's not measured!")
		(_metric_signals[metric] as Signal).emit(value)

	func _to_data() -> Dictionary:
		var result := {}

		# Add custom measures
		for measure in _measures:
			var name := "%s - %s" % [measure.get_metric_name(), measure.get_measure_name().capitalize()]
			result[name] = str(measure.get_value())

		# Add builtin measures
		if _enable_builtin_measures:
			result["iterations"] = _iterations
			result["duration"] = "%.4fms" % [_duration * 1000.0]
			result["iters/sec"] = get_iters_per_sec()
			result["average iteration time"] = "%.4fms" % [get_avg_iteration_time() * 1000.0]

		# Add benchmark data
		result["name"] = name

		return result
