extends VestTest

func get_suite_name():
	return "Benchmarks"

func test_emit_performance():
	benchmark("Single metric, single measurement", func(emit: Callable):
		emit.call(&"value", randf())
	)\
		.measure_value(&"value")\
		.with_iterations(10_000)\
		.with_batch_size(2_000)\
		.run()

	benchmark("Single metric, multiple measurements", func(emit: Callable):
		emit.call(&"value", randf())
	)\
		.measure_value(&"value")\
		.measure_value(&"value")\
		.measure_value(&"value")\
		.measure_value(&"value")\
		.with_iterations(10_000)\
		.with_batch_size(2_000)\
		.run()

	benchmark("Multiple metrics, multiple measurements", func(emit: Callable):
		emit.call(&"1", randf())
		emit.call(&"2", randf())
		emit.call(&"3", randf())
		emit.call(&"4", randf())
	)\
		.measure_value(&"1")\
		.measure_value(&"2")\
		.measure_value(&"3")\
		.measure_value(&"4")\
		.with_iterations(10_000)\
		.with_batch_size(2_000)\
		.run()
