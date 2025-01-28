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
		)
	)

func test_something():
	ok()

func _run():
	var runner := VestRunner.new()
	var results := runner.run_instance(self)

	print("Results: \n%s" % ["\n".join(results)])
	print("Report: \n%s" % [TAPReporter.report(results)])
