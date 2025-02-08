@tool
extends VestTest
class_name RunVest

@export var do_run: bool = false

func _process(_dt):
	if do_run:
		_run_daemon()
		do_run = false

func suite() -> VestDefs.Suite:
	return define("Some suite", func():
		test("Should pass", func(): expect(true))
		test("Should fail", func(): expect(false))
		test("Should be empty", func(): expect_empty([]))
		test("Skip", func(): skip())

		define("Sub suite", func():
			test("TODO", func(): todo())
			test("Compare", func(): expect_equal(2, 3))
		)

		benchmark("RNG perf test", func():
			randi()
		).with_timeout(0.1)
	)

func test_something():
	haha()
	ok()

func test_with_params(a, b, expected, params = "params_provider"):
	expect_equal(a + b, expected)

func benchmark_rng(iterations: int = 1000, timeout: float = 1.0):
	randi()

func before_suite(what):
	print("Before Suite: %s" % [what])

func before_case(what):
	print("Before Case: %s" % [what])

func before_benchmark(what):
	print("Before Benchmark: %s" % [what])

func after_suite(what):
	print("After Suite: %s" % [what])

func after_case(what):
	print("After Case: %s" % [what])

func after_benchmark(what):
	print("After Benchmark: %s" % [what])

func params_provider():
	return [
		[1, 3, 2, 4],
		["foo", "bar", "foobar"]
	]

func _run_daemon():
	var runner := VestDaemonRunner.new()
	add_child(runner)
	
	print(runner._glob("res://*.test.gd"))
	return

	var result = runner.run_script_at("res://tests/parameterized.test.gd")
	print(TAPReporter.report(result))

	runner.queue_free()
