extends VestTest

func get_suite_name() -> String:
	return "Benchmarks"

func suite():
	test("Random ID generation", func():
		var length := 16
		var charset := "abcdefghijklmnopqrstuvwxyz0123456789"

		var concat := benchmark("String concatenation", func():
			var _id := ""
			for i in range(length):
				_id += charset[randi() % charset.length()]
		).with_iterations(1_000).run()

		var rangemap := benchmark("Range mapping", func():
			var _id := "".join(
				range(length)
					.map(func(__): return charset[randi() % charset.length()])
				)
		).with_iterations(1_000).run()

		var psa := benchmark("PackedStringArray", func():
			var chars := PackedStringArray()
			for i in range(length):
				chars.append(charset[randi() % charset.length()])
			var _id := "".join(chars)
		).with_iterations(1_000).run()

		expect(concat.get_iters_per_sec() > 100_000, "Concatenation was too slow!")
		expect(rangemap.get_iters_per_sec() > 100_000, "Rangemapping was too slow!")
		expect(psa.get_iters_per_sec() > 100_000, "PackedStringArray was too slow!")
	)

	test("Array serialization", func():
		var buffer := StreamPeerBuffer.new()

		benchmark("Array", func():
			buffer.clear()
			buffer.put_var([1, 2, 3, 4])
		).with_metric("Size", func(): return buffer.get_size()).once()

		benchmark("PackedInt32Array", func():
			buffer.clear()
			buffer.put_var(PackedInt32Array([1, 2, 3, 4]))
		).with_metric("Size", func(): return buffer.get_size()).once().attach_metric("Size", func(): return buffer.get_size())
	)

func test_random_id_generation():
	var length := 16
	var charset := "abcdefghijklmnopqrstuvwxyz0123456789"

	var concat := benchmark("String concatenation", func():
		var _id := ""
		for i in range(length):
			_id += charset[randi() % charset.length()]
	).with_iterations(1_000).run()

	var rangemap := benchmark("Range mapping", func():
		var _id := "".join(
			range(length)
				.map(func(__): return charset[randi() % charset.length()])
			)
	).with_iterations(1_000).run()

	var psa := benchmark("PackedStringArray", func():
		var chars := PackedStringArray()
		for i in range(length):
			chars.append(charset[randi() % charset.length()])
		var _id := "".join(chars)
	).with_iterations(1_000).run()

	expect(concat.get_iters_per_sec() > 100_000, "Concatenation was too slow!")
	expect(rangemap.get_iters_per_sec() > 100_000, "Rangemapping was too slow!")
	expect(psa.get_iters_per_sec() > 100_000, "PackedStringArray was too slow!")
