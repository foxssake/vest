extends VestTestMixin

## Mixin for asserting test requirement
##
## @tutorial(Assertiongs): https://foxssake.github.io/vest/user-guide/assertions/

## Expect a [param condition] to be true.
func expect(condition: bool, p_message: String = "") -> void:
	if condition:
		ok()
	else:
		fail(p_message)

## Expect a [param condition] to be false.
func expect_not(condition: bool, p_message: String = "") -> void:
	if not condition:
		ok()
	else:
		fail(p_message)

## Expect two values to be equal.
## [br][br]
## If [param actual] has an [code]equals()[/code] method, it will be used.
func expect_equal(actual: Variant, expected: Variant, p_message: String = "Actual value differs from expected!") -> void:
	if _is_equal(actual, expected):
		ok()
	else:
		fail(p_message, { "expect": expected, "got": actual })

## Expect two values to be equal.
## [br][br]
## If [param actual] has an [code]equals()[/code] method, it will be used.
func expect_not_equal(actual: Variant, expected: Variant, p_message: String = "Actual value equals expected!") -> void:
	if _is_equal(actual, expected):
		fail(p_message, { "expect": expected, "got": actual })
	else:
		ok()

## Expect a [param condition] to be true.
## [br][br]
## Synonim of [method expect], aimed at better readability for asserting bools.
func expect_true(condition: bool, p_message: String = "") -> void:
	expect(condition, p_message)

## Expect a [param condition] to be false.
## [br][br]
## Synonim of [method expect_not], aimed at better readability for asserting
## bools.
func expect_false(condition: bool, p_message: String = "") -> void:
	expect_not(condition, p_message)

## Expect an [param object] to be empty.
## [br][br]
## If it's a custom type implementing [code]is_empty()[/code], that method will
## be used.
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

## Expect an [param object] to not be empty.
## [br][br]
## If it's a custom type implementing [code]is_empty()[/code], that method will
## be used.
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

## Expect an [param object] to contain an [param item].
## [br][br]
## If it's a custom type implementing [code]has()[/code], that method will be
## used.
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

## Expect an [param object] to not contain an [param item].
## [br][br]
## If it's a custom type implementing [code]has()[/code], that method will be
## used.
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

func _is_equal(actual, expected) -> bool:
	if actual is Object and actual.has_method("equals"):
		return actual.equals(expected)
	return actual == expected

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
