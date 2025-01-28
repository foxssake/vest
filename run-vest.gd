@tool
extends VestTest

@export var do_run: bool = false

func _ready():
	if not Engine.is_editor_hint():
		run()

func _process(_dt):
	if do_run:
		run()
		do_run = false

func run():
	var suite = define("Some suite", func():
		test("Should pass", func(): ok())
		test("Should fail", func(): fail())
		test("Skip", func(): skip())

		define("Sub suite", func():
			test("TODO", func(): todo())
		)
	)

	var runner := VestRunner.new()
	var results := runner.run_suite(suite)

	print("Suite: %s" % [suite])
	print("Results: \n%s" % ["\n".join(results)])
