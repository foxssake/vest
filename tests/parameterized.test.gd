extends VestTest

func get_suite_name() -> String:
	return "Parameterized"

func params_provider():
	return [
		[2, 5, 7],
		["foo", "bar", "foobar"],
		[[1, 2], [3, 0], [1, 2, 3, 0]]
	]

func test_addition(a, b, expected, _params="params_provider"):
	expect_equal(a + b, expected)
