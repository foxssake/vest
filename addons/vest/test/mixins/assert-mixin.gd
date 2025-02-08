extends VestTestMixin

func expect(condition: bool, p_message: String = "") -> void:
	if condition:
		ok()
	else:
		fail(p_message)

func expect_not(condition: bool, p_message: String = "") -> void:
	if not condition:
		ok()
	else:
		fail(p_message)

func expect_equal(actual: Variant, expected: Variant) -> void:
	var equals = actual == expected
	if actual is Object and actual.has_method("equals"):
		equals = actual.equals(expected)

	if equals:
		ok()
	else:
		fail("Actual value differs from expected!", { "expect": expected, "got": actual })

func expect_not_equal(actual: Variant, expected: Variant) -> void:
	if actual == expected:
		fail("Actual value equals expected!", { "expect": expected, "got": actual })
	else:
		ok()

func expect_true(condition: bool, p_message: String = "") -> void:
	expect(condition, p_message)

func expect_false(condition: bool, p_message: String = "") -> void:
	expect_not(condition, p_message)

func expect_empty(object: Variant, p_message: String = "Object was not empty!") -> void:
	if object is Array or object is Dictionary:
		expect(object.is_empty(), p_message)
	elif object is Object:
		if object.has_method("is_empty"):
			expect(object.is_empty(), p_message)
		else:
			fail("Object has no is_empty() method!", { "object": object })
	else:
		fail("Unknown object, can't be checked for emptiness!", { "object": object })

func expect_contains(object: Variant, item: Variant, p_message: String = "Item is missing from collection!") -> void:
	var data = { "got": object, "missing": item }
	var contains = false

	if object is Array or object is Dictionary:
		contains = object.has(item)
	elif object is Object:
		if object.has_method("has"):
			contains = object.has(item)
		else:
			return fail("Object has no has() method!", { "object": object })
	else:
		return fail("Unknown object, can't be checked if it contains item!", { "object": object })

	if contains:
		ok()
	else:
		fail(p_message, data)
