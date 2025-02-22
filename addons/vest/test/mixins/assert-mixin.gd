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

func expect_equal(actual: Variant, expected: Variant, p_message: String = "Actual value differs from expected!") -> void:
	var equals = actual == expected
	if actual is Object and actual.has_method("equals"):
		equals = actual.equals(expected)

	if equals:
		ok()
	else:
		fail(p_message, { "expect": expected, "got": actual })

func expect_not_equal(actual: Variant, expected: Variant, p_message: String = "Actual value equals expected!") -> void:
	if actual == expected:
		fail(p_message, { "expect": expected, "got": actual })
	else:
		ok()

func expect_true(condition: bool, p_message: String = "") -> void:
	expect(condition, p_message)

func expect_false(condition: bool, p_message: String = "") -> void:
	expect_not(condition, p_message)

func expect_empty(object: Variant, p_message: String = "Object was not empty!") -> void:
	match _is_empty(object):
		true:
			ok()
		false:
			fail(p_message)
		ERR_METHOD_NOT_FOUND:
			fail("Object has no is_empty() method!", { "object": object })
		ERR_CANT_RESOLVE:
			fail("Unknown object, can't be checked for emptiness!", { "object": object })

func expect_not_empty(object: Variant, p_message: String = "Object was empty!") -> void:
	match _is_empty(object):
		true:
			fail(p_message)
		false:
			ok()
		ERR_METHOD_NOT_FOUND:
			fail("Object has no is_empty() method!", { "object": object })
		ERR_CANT_RESOLVE:
			fail("Unknown object, can't be checked for emptiness!", { "object": object })

func expect_contains(object: Variant, item: Variant, p_message: String = "Item is missing from collection!") -> void:
	match _contains(object, item):
		true:
			ok()
		false:
			fail(p_message, { "got": object, "missing": item })
		ERR_METHOD_NOT_FOUND:
			fail("Object has no has() method!", { "object": object })
		ERR_CANT_RESOLVE:
			fail("Unknown object, can't be checked if it contains item!", { "object": object })

func expect_doesnt_contain(object: Variant, item: Variant, p_message: String = "Item is in collection!") -> void:
	match _contains(object, item):
		true:
			fail(p_message, { "got": object, "excess": item })
		false:
			ok()
		ERR_METHOD_NOT_FOUND:
			fail("Object has no has() method!", { "object": object })
		ERR_CANT_RESOLVE:
			fail("Unknown object, can't be checked if it contains item!", { "object": object })

func _is_empty(object: Variant) -> Variant:
	if object is Array or object is Dictionary:
		return object.is_empty()
	elif object is Object:
		if object.has_method("is_empty"):
			return object.is_empty()
		else:
			return ERR_METHOD_NOT_FOUND
	else:
		return ERR_CANT_RESOLVE

func _contains(object: Variant, item: Variant) -> Variant:
	if object is Array or object is Dictionary:
		return object.has(item)
	elif object is Object:
		if object.has_method("has"):
			return object.has(item)
		else:
			return ERR_METHOD_NOT_FOUND
	else:
		return ERR_CANT_RESOLVE
