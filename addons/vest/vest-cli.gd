extends SceneTree

func _init():
	var runner := VestLocalRunner.new()
	root.add_child(runner)

	var results := runner.run_glob("res://*.test.gd")
	runner.free()

	print(TAPReporter.report(results))

	quit(0)
