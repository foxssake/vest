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
	ok()

func benchmark_rng(iterations: int = 1000, timeout: float = 1.0):
	randi()

func _run_daemon():
	VestMixins._generate_mixin_chain([])
	return
	
	var runner := VestRunner.new()
	add_child(runner)

	var result = await runner.run_script_in_background(load("res://tests/mocks.test.gd"))
	print(TAPReporter.report(result))

	runner.queue_free()
