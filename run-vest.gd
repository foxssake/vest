@tool
extends VestTest
class_name RunVest

@export var do_run: bool = false

func _ready():
	if not Engine.is_editor_hint():
		_run()

func _process(_dt):
	if do_run:
		_run()
		do_run = false

func test_with_suite() -> VestSuite:
	return define("Some suite", func():
		test("Should pass", func(): expect(true))
		test("Should fail", func(): expect(false))
		test("Should be empty", func(): expect_empty([]))
		test("Skip", func(): skip())

		define("Sub suite", func():
			test("TODO", func(): todo())
			test("Compare", func(): expect_equal(2, 3))
		)
	)

func test_something():
	ok()

func _run():
	var runner := VestRunner.new()
	var result := runner.run_instance(self)

	print("Results: \n%s" % [result])
	print("Report: \n%s" % [TAPReporter.report(result)])
