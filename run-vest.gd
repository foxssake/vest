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
	print(YAMLWriter.stringify({
		"int": 3,
		"float": 2.4,
		"string": "Heyoo",
		"wordy entry": 75,
		"array": [1, 2, 3],
		"dictionary": { "foo": 2, "bar": 3 },
		"nested array": [[1, 2], [3, 4]],
		"single entry dict": { "foo": 2 }
	}))

	return
	var runner := VestRunner.new()
	var results := runner.run_instance(self)
	print("Results: \n%s" % ["\n".join(results)])
