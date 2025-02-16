extends VestTest

func get_suite_name() -> String:
	return "Parameterized tests"

func suite():
	var cases := [
		["simple", "Simple"],
		["two_words", "Two Words"],
		["camelCase", "Camel Case"]
	]

	for i in range(cases.size()):
		test("Capitalize #" + str(i+1), func():
			expect_equal(cases[i][0].capitalize(), cases[i][1])
		)

func provide_capitalize_params() -> Array:
	return [
		["simple", "Simple"],
		["two_words", "Two Words"],
		["camelCase", "Camel Case"]
	]

func test_capitalize(input: String, expected: String, _params="provide_capitalize_params"):
	expect_equal(input.capitalize(), expected)
