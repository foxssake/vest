extends Node

func _ready():
	print("Creating runner")
	var runner := VestLocalRunner.new()
	add_child(runner)

	print("Registering message handlers")

	EngineDebugger.register_message_capture("vest:file", func(message: String, data: Array):
		print("Running file!")
		var file := data[0] as String
		var results := await runner.run_script_at(file)
		EngineDebugger.send_message("vest:result", [results._to_wire()])
		get_tree().quit(0)
		return true
	)

	EngineDebugger.register_message_capture("vest:glob", func(message: String, data: Array):
		print("Running glob!")
		var glob := data[0] as String
		var results := await runner.run_glob(glob)
		EngineDebugger.send_message("vest:result", [results._to_wire()])
		get_tree().quit(0)
		return true
	)
