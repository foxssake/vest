extends VestTest

func get_suite_name() -> String:
	return "expect()"

func suite():
	test("exp 0 should return 1", func():
		expect_equal(1, pow(128, 0))
	)
	test("exp 1 should return input", func():
		expect_equal(128, pow(128, 1))
	)

func test_exp_0_should_return_1():
	expect_equal(1, pow(128, 0))

func test_exp_1_should_return_inpt():
	expect_equal(128, pow(128, 1))
