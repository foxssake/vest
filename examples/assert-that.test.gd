extends VestTest

func get_suite_name() -> String:
	return "assert_that()"

func test_asserts():
	var values := [1, 4, 3]

	assert_that(values)\
		.is_not_null()\
		.is_not_empty()\
		.contains(4)\
		.does_not_contain(2)\
		.is_not_equal_to([1, 2])\
		.passes(func(it): return it.size() == 3, "Array should contain 3 items!")\
		.fails(func(it): return it.max() > 6, "Items should be lesser than 6!")
