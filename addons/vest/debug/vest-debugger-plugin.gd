extends EditorDebuggerPlugin

var editor_interface: EditorInterface

func _setup_session(session_id):
	var session := get_session(session_id)
	print("Received session ", session_id, " ", session, " ", Engine.is_editor_hint())

	session.started.connect(func ():
		print("Started session", session_id, " ", Engine.is_editor_hint())

		for i in range(8):
			await editor_interface.get_tree().create_timer(0.1).timeout
			session.send_message("vest:glob", [VestEditorPlugin.get_test_glob()])
			print("Sent a glob message")
	)
	session.stopped.connect(func (): print("Session stopped"))

func _has_capture(capture):
	return capture == "vest"

func _capture(message, data, session_id):
	print("Received message! %s > %s" % [message, data])
	if message == "vest:result":
		var results := VestResult.Suite._from_wire(data[0])
		print(TAPReporter.report(results))

	return true
