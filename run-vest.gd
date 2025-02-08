@tool
extends VestTest
class_name RunVest

@export var do_run: bool = false

func _process(_dt):
	if do_run:
		_run_daemon()
		do_run = false

func test_with_suite() -> VestDefs.Suite:
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

func _run_daemon():
	var runner := VestRunner.new()
	add_child(runner)

#	var result = await runner.run_script_in_background(load("res://tests/mocks.test.gd"))
	var result = runner.run_instance(self)
	print(TAPReporter.report(result))

	runner.queue_free()
