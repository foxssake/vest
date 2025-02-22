extends VestTest

func get_suite_name() -> String:
	return "Your first test"

func suite():
	test("Addition", func():
		expect_equal(2 * 2, 4)
	)

func test_addition():
	expect_equal(2 * 2, 4)
