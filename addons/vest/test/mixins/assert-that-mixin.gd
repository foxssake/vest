extends VestTestMixin

func assert_that(value: Variant) -> Assertion:
	return Assertion.new(self, value)

class Assertion:
	var _test: VestTest
	var _value: Variant
	
	func _init(p_test: Variant, p_value: Variant):
		assert(p_test is VestTest, "assert_that mixin used from outside of VestTest!")

		_test = p_test
		_value = p_value

	func is_equal_to(expected: Variant, p_message: String = "Actual value differs from expected!") -> Assertion:
		_test.expect_equal(_value, expected, p_message)
		return self

	func is_not_equal_to(expected: Variant, p_message: String = "Actual value equals expected!") -> Assertion:
		_test.expect_not_equal(_value, expected, p_message)
		return self

	func is_empty(p_message: String = "Object was not empty!") -> Assertion:
		_test.expect_empty(_value, p_message)
		return self

	func is_not_empty(p_message: String = "Object was empty!") -> Assertion:
		_test.expect_not_empty(_value, p_message)
		return self

	func contains(item: Variant, p_message: String = "Item is missing from collection!") -> Assertion:
		_test.expect_contains(_value, item, p_message)
		return self

	func does_not_contain(item: Variant, p_message: String = "Item is in collection!") -> Assertion:
		_test.expect_does_not_contain(_value, item, p_message)
		return self

	func is_null(p_message: String = "Item is not null!") -> Assertion:
		_test.expect_null(_value, p_message)
		return self

	func is_not_null(p_message: String = "Item is null!") -> Assertion:
		_test.expect_not_null(_value, p_message)
		return self
