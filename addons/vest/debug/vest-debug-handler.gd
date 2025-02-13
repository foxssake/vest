extends Node

func _ready():
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MINIMIZED)

	var runner := VestLocalRunner.new()
	runner.run_glob(Vest.get_test_glob())

	get_tree().quit()
