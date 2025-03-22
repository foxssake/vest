# This file is generated by Vest!
# Do not modify!
# source: res://addons/vest/test/mixins/assert-mixin.gd
extends "res://addons/vest/_generated-mixins/1-8182042.gd"



## Mixin for asserting test requirement
##
## @tutorial(Assertions): https://foxssake.github.io/vest/latest/user-guide/assertions/

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

## Expect a [param value] to be null.
func expect_null(value: Variant, p_message: String = "Item is not null!") -> void:
	if value == null:
		ok()
	else:
		fail(p_message, { "got": value })

## Expect a [param value] to not be null.
func expect_not_null(value: Variant, p_message: String = "Item is null!") -> void:
	if value != null:
		ok()
	else:
		fail(p_message)

func _is_equal(actual, expected) -> bool:
	if actual is Object and actual.has_method("equals"):
		return actual.equals(expected)
	return actual == expected

func _is_empty(object: Variant) -> Variant:
	if _is_builtin_container(object) or _is_stringlike(object):
		return object.is_empty()
	elif object is Object:
		if object.has_method("is_empty"):
			return object.is_empty()
		else:
			return ERR_METHOD_NOT_FOUND
	else:
		return ERR_CANT_RESOLVE

func _contains(object: Variant, item: Variant) -> Variant:
	if _is_builtin_container(object):
		return object.has(item)
	elif _is_stringlike(object):
		return object.contains(str(item))
	elif object is Object:
		if object.has_method("has"):
			return object.has(item)
		else:
			return ERR_METHOD_NOT_FOUND
	else:
		return ERR_CANT_RESOLVE

func _is_builtin_container(object: Variant) -> bool:
	return object is Array or object is Dictionary \
		or object is PackedByteArray or object is PackedColorArray \
		or object is PackedFloat32Array or object is PackedFloat64Array \
		or object is PackedInt32Array or object is PackedInt64Array \
		or object is PackedStringArray \
		or object is PackedVector2Array or object is PackedVector3Array

func _is_stringlike(object: Variant) -> bool:
	return object is String or object is StringName or object is NodePath
