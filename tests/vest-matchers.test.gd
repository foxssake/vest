extends VestTest

const Matchers := Vest.__.Matchers

func get_suite_name():
	return "Matchers"

func suite():
	define("equals", func():
		test("string", func():
			expect(Matchers.is_equal("foo", "foo"))
		)

		test("string name", func():
			expect(Matchers.is_equal(&"bar", &"bar"))
		)

		test("array", func():
			expect(Matchers.is_equal([1, 2], [1, 2]))
		)

		test("dictionary", func():
			expect(Matchers.is_equal({ 1: 2 }, { 1: 2 }))
		)

		test("custom", func():
			expect(Matchers.is_equal(CustomContainer.new([1, 2]), CustomContainer.new([1, 2])))
		)

		test("custom without overloads", func():
			expect_not(Matchers.is_equal(RawCustomContainer.new([1, 2]), RawCustomContainer.new([1, 2])))
		)
	)

	define("is_empty", func():
		test("string", func():
			expect(Matchers.is_empty(""))
			expect_not(Matchers.is_empty("foo"))
		)

		test("string name", func():
			expect(Matchers.is_empty(&""))
			expect_not(Matchers.is_empty(&"foo"))
		)

		test("array", func():
			expect(Matchers.is_empty([]))
			expect_not(Matchers.is_empty([1, 2]))
		)

		test("dictionary", func():
			expect(Matchers.is_empty({ }))
			expect_not(Matchers.is_empty({ "foo": 1 }))
		)

		test("custom", func():
			expect(Matchers.is_empty(CustomContainer.new([])))
			expect_not(Matchers.is_empty(CustomContainer.new([1, 2])))
		)

		test("custom without overloads", func():
			expect(Matchers.is_empty(RawCustomContainer.new([1, 2])) == ERR_METHOD_NOT_FOUND)
		)
	)

	define("contains", func():
		test("string", func():
			expect(Matchers.contains("foobar", "oba"))
			expect(Matchers.contains("f00bar", 0))
			expect_not(Matchers.contains("foobar", "quix"))
		)

		test("string name", func():
			expect(Matchers.contains(&"foobar", &"oba"))
			expect(Matchers.contains(&"f00bar", 0))
			expect_not(Matchers.contains(&"foobar", &"quix"))
		)

		test("array", func():
			expect(Matchers.contains([1, 2, 3], 2))
			expect_not(Matchers.contains([1, 2, 3], 4))
		)

		test("dictionary", func():
			expect(Matchers.contains({ "foo": 1 }, "foo"))
			expect_not(Matchers.contains({ "foo": 1 }, "bar"))
		)

		test("custom", func():
			expect(Matchers.contains(CustomContainer.new([1, 2, 3]), 2))
			expect_not(Matchers.contains(CustomContainer.new([1, 2, 3]), 4))
		)

		test("custom without overloads", func():
			expect(Matchers.contains(RawCustomContainer.new([1, 2]), 2) == ERR_METHOD_NOT_FOUND)
		)
	)

class CustomContainer:
	var _values: Array
	
	func _init(p_values: Array):
		_values = p_values.duplicate()

	func size() -> int:
		return _values.size()

	func is_empty() -> bool:
		return _values.is_empty()

	func equals(other: Variant) -> bool:
		if not other: return false
		if not other is CustomContainer: return false
		return _values == other._values

	func has(item: Variant) -> bool:
		return _values.has(item)

class RawCustomContainer:
	var _values: Array

	func _init(p_values: Array):
		_values = p_values.duplicate()
