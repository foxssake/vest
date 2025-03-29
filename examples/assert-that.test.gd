extends VestTest

func get_suite_name() -> String:
	return "assert_that()"

func test_asserts():
	var values := [1, 4, 3]

	assert_that(values)\
		.is_not_null()\
		.is_not_empty()\
		.contains(4)\
		.doesnt_contain(2)\
		.is_not_equal_to([1, 2])
