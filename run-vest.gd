@tool
extends VestTest
class_name RunVest

@export var do_run: bool = false

func _ready():
	return
	if not Engine.is_editor_hint():
		OS.alert(str(OS.get_process_id()))
		_run()

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
	)

func test_something():
	ok()

func _run():
	var runner := VestRunner.new()
	add_child(runner)
	var result := runner.run_instance(self)

	print("Results: \n%s" % [result])
	print("Report: \n%s" % [TAPReporter.report(result)])

	runner.queue_free()

func _run_daemon():
	var runner := VestRunner.new()
	add_child(runner)

	var result = await runner.run_in_background(self)
	print(TAPReporter.report(result))

#	runner.queue_free()
