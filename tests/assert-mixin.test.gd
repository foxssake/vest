extends VestTest

func get_suite_name() -> String:
	return "Asserts"

func suite():
	define("contains", func():
		test("Array", func():
			expect_contains([1, 2, 3], 2)
			expect_doesnt_contain([1, 2, 3], 4)
		)

		test("Dictionary", func():
			expect_contains({ "foo": 1, "bar": 2 }, "foo")
			expect_doesnt_contain({ "foo": 1, "bar": 2 }, 1)
		)

		test("String", func():
			expect_contains("foobar", "foo")
			expect_doesnt_contain("foobar", "quix")
		)

		test("StringName", func():
			expect_contains(&"foobar", &"foo")
			expect_doesnt_contain(&"foobar", &"quix")
		)

		test("Custom", func():
			expect_contains(CustomContainer.new(1), 1)
			expect_doesnt_contain(CustomContainer.new(2), 1)
		)
	)

	define("expect_null", func():
		test("null", func(): expect_null(null))
		test("not null", func(): expect_not_null(2))
	)

	define("expect_empty", func():
		test("Array", func(): expect_empty([]); expect_not_empty([ 1 ]))
		test("Dictionary", func(): expect_empty({}); expect_not_empty({ 1: 2 }))
		test("String", func(): expect_empty(""); expect_not_empty("foo"))
		test("StringName", func(): expect_empty(&""); expect_not_empty(&"bar"))
	)

class CustomContainer:
	var value: Variant
	
	func _init(p_value: Variant):
		value = p_value

	func has(p_value: Variant) -> bool:
		return value == p_value
