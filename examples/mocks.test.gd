extends VestTest

func get_suite_name() -> String:
	return "Mocks"

var simple_math: SimpleMath

func suite():
	on_case_begin.connect(func(__):
		simple_math = mock(SimpleMath)

		# Specify default answers
		when(simple_math.times).then_return(0)
		when(simple_math.sum).then_return(0)
	)

	test("Return configured answer", func():
		when(simple_math.times).with_args([2.0, 2.0]).then_return(5)
		expect_equal(simple_math.times(2, 2), 5)
	)

	test("Method was called at least once", func():
		simple_math.times(4, 4)

		var calls := get_calls_of(simple_math.times)
		expect(not calls.is_empty(), "Method was not called!")
	)

	test("Method was called with parameters", func():
		simple_math.times(2, 4)
		expect_contains(get_calls_of(simple_math.times), [2.0, 4.0])
	)

func before_case(__):
	simple_math = mock(SimpleMath)

	# Specify default answers
	when(simple_math.times).then_return(0)
	when(simple_math.sum).then_return(0)

func test_return_configured_answer():
	when(simple_math.times).with_args([2.0, 2.0]).then_return(5)
	expect_equal(simple_math.times(2, 2), 5)

func test_method_was_called_at_least_once():
	simple_math.times(4, 4)

	var calls := get_calls_of(simple_math.times)
	expect(not calls.is_empty(), "Method was not called!")

func test_method_was_called_with_parameters():
	simple_math.times(2, 4)
	expect_contains(get_calls_of(simple_math.times), [2.0, 4.0])
