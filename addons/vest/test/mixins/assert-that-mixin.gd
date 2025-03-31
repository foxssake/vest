extends VestTestMixin

func assert_that(value: Variant) -> _Assertion:
	return _Assertion.new(self, value)

class _Assertion:
	var _test: VestTest
	var _value: Variant
	
	func _init(p_test: Variant, p_value: Variant):
		assert(p_test is VestTest, "assert_that mixin used from outside of VestTest!")

		_test = p_test
		_value = p_value

	## Expect a [param condition] about the asserted value to be true.
	func passes(condition: Callable, p_message: String = "") -> _Assertion:
		_test.expect(condition.call(_value), p_message)
		return self

	## Expect a [param condition] about the asserted value to be false.
	func fails(condition: Callable, p_message: String = "") -> _Assertion:
		_test.expect_not(condition.call(_value), p_message)
		return self

	## Expect the asserted value to be equal to [param expected].
	## [br][br]
	## If [param actual] has an [code]equals()[/code] method, it will be used.
	func is_equal_to(expected: Variant, p_message: String = "Actual value differs from expected!") -> _Assertion:
		_test.expect_equal(_value, expected, p_message)
		return self

	## Expect the asserted value to not be equal to [param expected].
	## [br][br]
	## If [param actual] has an [code]equals()[/code] method, it will be used.
	func is_not_equal_to(expected: Variant, p_message: String = "Actual value equals expected!") -> _Assertion:
		_test.expect_not_equal(_value, expected, p_message)
		return self

	## Expect the asserted value to be empty.
	## [br][br]
	## If it's a custom type implementing [code]is_empty()[/code], that method will
	## be used.
	func is_empty(p_message: String = "Object was not empty!") -> _Assertion:
		_test.expect_empty(_value, p_message)
		return self

	## Expect the asserted value to not be empty.
	## [br][br]
	## If it's a custom type implementing [code]is_empty()[/code], that method will
	## be used.
	func is_not_empty(p_message: String = "Object was empty!") -> _Assertion:
		_test.expect_not_empty(_value, p_message)
		return self

	## Expect the asserted value to contain [param item].
	## [br][br]
	## If it's a custom type implementing [code]has()[/code], that method will be
	## used.
	func contains(item: Variant, p_message: String = "Item is missing from collection!") -> _Assertion:
		_test.expect_contains(_value, item, p_message)
		return self

	## Expect the asserted value to not contain [param item].
	## [br][br]
	## If it's a custom type implementing [code]has()[/code], that method will be
	## used.
	func does_not_contain(item: Variant, p_message: String = "Item is in collection!") -> _Assertion:
		_test.expect_does_not_contain(_value, item, p_message)
		return self

	## Expect the asserted value to be null.
	func is_null(p_message: String = "Item is not null!") -> _Assertion:
		_test.expect_null(_value, p_message)
		return self

	## Expect the asserted value to not be null.
	func is_not_null(p_message: String = "Item is null!") -> _Assertion:
		_test.expect_not_null(_value, p_message)
		return self
