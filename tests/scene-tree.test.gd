extends VestTest

func get_suite_name():
	return "SceneTree"

func suite():
	test("should process frames", func():
		var frames_before := Engine.get_process_frames()
		await Vest.get_tree().process_frame
		var frames_after := Engine.get_process_frames()

		expect(frames_after > frames_before)
	)
