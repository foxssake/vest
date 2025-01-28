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
	print("Some suites:", [
		define("Some suite", func():
			test("Should pass", func(): return false)
			test("Some other  test", func(): return false)
			),
		define("Another suite", func():
			test("Should return false", func(): return false)
			)
	])
