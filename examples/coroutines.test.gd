extends VestTest

func get_suite_name() -> String:
	return "Coroutines"

func suite():
	# Coroutines are also supported when defining tests
	await Vest.sleep()

	# Async define()'s are supported too
	# NOTE: Make sure to `await` async defines!
	await define("Async suite", func():
		# Think a bit before specifying the test
		await Vest.sleep()
		
		test("Think of a number", func():
			var number := await think_of_a_number()

			expect_contains(range(0, 10), number)
		)
	)

	# Async signal handlers are also supported
	on_begin.connect(func(): await Vest.sleep())
	on_finish.connect(func(): await Vest.sleep())

func test_think_of_a_number():
	var number := await think_of_a_number()

	expect_contains(range(0, 10), number)

func think_of_a_number() -> int:
	# Think for a bit
	await Vest.sleep()
	return randi() % 10

func before_all():
	await Vest.sleep()

func after_all():
	await Vest.sleep()
