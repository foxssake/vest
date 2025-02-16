extends VestTest

func get_suite_name() -> String:
	return "Benchmarks"

func suite():
	test("Random ID generation", func():
		var length := 16
		var charset := "abcdefghijklmnopqrstuvwxyz0123456789"

		benchmark("String concatenation", func():
			var _id := ""
			for i in range(length):
				_id += charset[randi() % charset.length()]
		).with_iterations(1_000).run()

		benchmark("Range mapping", func():
			var _id := "".join(
				range(length)
					.map(func(__): return charset[randi() % charset.length()])
				)
		).with_iterations(1_000).run()

		benchmark("PackedStringArray", func():
			var chars := PackedStringArray()
			for i in range(length):
				chars.append(charset[randi() % charset.length()])
			var _id := "".join(chars)
		).with_iterations(1_000).run()
	)

func test_random_id_generation():
	var length := 16
	var charset := "abcdefghijklmnopqrstuvwxyz0123456789"

	benchmark("String concatenation", func():
		var _id := ""
		for i in range(length):
			_id += charset[randi() % charset.length()]
	).with_iterations(1_000).run()

	benchmark("Range mapping", func():
		var _id := "".join(
			range(length)
				.map(func(__): return charset[randi() % charset.length()])
			)
	).with_iterations(1_000).run()

	benchmark("PackedStringArray", func():
		var chars := PackedStringArray()
		for i in range(length):
			chars.append(charset[randi() % charset.length()])
		var _id := "".join(chars)
	).with_iterations(1_000).run()
