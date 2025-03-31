extends VestTest

func get_suite_name() -> String:
	return "assert_that()"

func suite():
	test("exp 0 should return 1", func():
		assert_that(pow(128, 0))\
			.is_not_null()\
			.is_equal_to(1)
	)
	test("exp 1 should return input", func():
		assert_that(pow(128, 1))\
			.is_not_null()\
			.is_equal_to(128)
	)

func test_exp_0_should_return_1():
	assert_that(pow(128, 0))\
		.is_not_null()\
		.is_equal_to(1)

func test_exp_1_should_return_inpt():
	assert_that(pow(128, 1))\
		.is_not_null()\
		.is_equal_to(128)
