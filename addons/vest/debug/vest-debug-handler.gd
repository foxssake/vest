extends Node

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

	var runner := VestLocalRunner.new()
	add_child(runner)

	var results := runner.run_glob(VestEditorPlugin.get_test_glob())

	get_tree().quit()
