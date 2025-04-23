extends VestTest

func get_suite_name() -> String:
	return "Benchmarks"

func suite():
	test("Random ID generation", func():
		var length := 16
		var charset := "abcdefghijklmnopqrstuvwxyz0123456789"

		var concat := benchmark("String concatenation", func(__):
			var _id := ""
			for i in range(length):
				_id += charset[randi() % charset.length()]
		).with_iterations(1_000).run()

		var rangemap := benchmark("Range mapping", func(__):
			var _id := "".join(
				range(length)
					.map(func(__): return charset[randi() % charset.length()])
				)
		).with_iterations(1_000).run()

		var psa := benchmark("PackedStringArray", func(__):
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

		var array := benchmark("Array", func(emit: Callable):
			buffer.clear()
			buffer.put_var([1, 2, 3, 4])
			emit.call(&"Size", buffer.get_size())
		)\
			.without_builtin_measures()\
			.measure_value(&"Size")\
			.once()

		var packed_array := benchmark("PackedInt32Array", func(emit):
			buffer.clear()
			buffer.put_var(PackedInt32Array([1, 2, 3, 4]))
			emit.call(&"Size", buffer.get_size())
		)\
			.without_builtin_measures()\
			.measure_value(&"Size")\
			.once()

		expect(array.get_measurement(&"Size", &"value") < 80, "Array too large!")
		expect(packed_array.get_measurement(&"Size", &"value") < 80, "PackedArray too large!")
	)

func test_random_id_generation():
	var length := 16
	var charset := "abcdefghijklmnopqrstuvwxyz0123456789"

	var concat := benchmark("String concatenation", func(__):
		var _id := ""
		for i in range(length):
			_id += charset[randi() % charset.length()]
	).with_iterations(1_000).run()

	var rangemap := benchmark("Range mapping", func(__):
		var _id := "".join(
			range(length)
				.map(func(__): return charset[randi() % charset.length()])
			)
	).with_iterations(1_000).run()

	var psa := benchmark("PackedStringArray", func(__):
		var chars := PackedStringArray()
		for i in range(length):
			chars.append(charset[randi() % charset.length()])
		var _id := "".join(chars)
	).with_iterations(1_000).run()

	expect(concat.get_iters_per_sec() > 100_000, "Concatenation was too slow!")
	expect(rangemap.get_iters_per_sec() > 100_000, "Rangemapping was too slow!")
	expect(psa.get_iters_per_sec() > 100_000, "PackedStringArray was too slow!")
