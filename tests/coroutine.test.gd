extends VestTest

func get_suite_name() -> String:
	return "Coroutine"

func suite():
	# Async suite methods are supported
	await Vest.sleep()

	# And even async tests
	test("await from suite", func():
		expect_equal(await Vest.sleep(), OK)
	)

	# And async define()'s
	# NOTE: Make sure to use `await` if the define's callback is a coroutine!
	await define("await in define()", func():
		await Vest.sleep()

		# And even async tests
		test("await from suite", func():
			expect_equal(await Vest.sleep(0.05), OK)
		)
	)

	# And even async lifecycle methods
	on_begin.connect(func(): await Vest.sleep())
	on_finish.connect(func(): await Vest.sleep())

func before_all():
	await Vest.sleep(0.)

func after_all():
	await Vest.sleep(0.)

func test_await_from_method():
	expect_equal(await Vest.sleep(), OK)
