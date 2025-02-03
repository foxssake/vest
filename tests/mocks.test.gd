extends VestTest

func test_should_return_default():
	# Given
	var expected := 8.
	var math_mock := mock(SimpleMath) as SimpleMath

	when(math_mock.times).then_return(expected)

	# When
	var actual = math_mock.times(7, 1)

	# Then
	expect_equal(actual, expected)

func test_should_return_on_args():
	# Given
	var expected := 8.
	var math_mock := mock(SimpleMath) as SimpleMath

	when(math_mock.times).with_args([7, 1]).then_return(expected)

	# When
	var actual = math_mock.times(7, 1)

	# Then
	expect_equal(actual, expected)

func test_should_return_default_on_wrong_args():
	# Given
	var expected := 8.
	var math_mock := mock(SimpleMath) as SimpleMath

	when(math_mock.times).with_args([1, 2]).then_return(-1.)
	when(math_mock.times).then_return(expected)

	# When
	var actual = math_mock.times(7, 1)

	# Then
	expect_equal(actual, expected)

func test_should_answer_default():
	# Given
	var expected := 8.
	var math_mock := mock(SimpleMath) as SimpleMath

	when(math_mock.times).then_answer(func(__): return 8.)

	# When
	var actual = math_mock.times(7, 1)

	# Then
	expect_equal(actual, expected)

func test_should_answer_on_args():
	# Given
	var expected := 8.
	var math_mock := mock(SimpleMath) as SimpleMath

	when(math_mock.times).with_args([7, 1]).then_answer(func(__): return expected)

	# When
	var actual = math_mock.times(7, 1)

	# Then
	expect_equal(actual, expected)

func test_should_answer_default_on_wrong_args():
	# Given
	var expected := 8.
	var math_mock := mock(SimpleMath) as SimpleMath

	when(math_mock.times).with_args([1, 2]).then_answer(func(__): return -1.)
	when(math_mock.times).then_answer(func(__): return expected)

	# When
	var actual = math_mock.times(7, 1)

	# Then
	expect_equal(actual, expected)
