extends VestTest

func get_suite_name() -> String:
	return "Coroutine"

func suite():
	# Async defines should work too
	await Vest.sleep(0.05)

	test("await from suite", func():
		expect_equal(await Vest.sleep(0.05), OK)
	)

func test_await_from_method():
	expect_equal(await Vest.sleep(0.05), OK)
