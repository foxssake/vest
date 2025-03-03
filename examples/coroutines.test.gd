extends VestTest

func get_suite_name() -> String:
	return "Coroutines"

func suite():
	# Coroutines are also supported when defining tests
	await Vest.sleep(0.01)

	test("Think of a number", func():
		var number := await think_of_a_number()

		expect_contains(range(0, 10), number)
	)

func test_think_of_a_number():
	var number := await think_of_a_number()

	expect_contains(range(0, 10), number)

func think_of_a_number() -> int:
	# Think for a bit
	await Vest.sleep(0.05)
	return randi() % 10
