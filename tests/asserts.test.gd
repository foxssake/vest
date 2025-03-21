extends VestTest

func get_suite_name() -> String:
	return "Asserts"

func suite():
	define("contains", func():
		test("array", func():
			expect_contains([1, 2, 3], 2)
			expect_doesnt_contain([1, 2, 3], 4)
		)

		test("dictionary", func():
			expect_contains({ "foo": 1, "bar": 2 }, "foo")
			expect_doesnt_contain({ "foo": 1, "bar": 2 }, 1)
		)

		test("custom", func():
			expect_contains(CustomContainer.new(1), 1)
			expect_doesnt_contain(CustomContainer.new(2), 1)
		)
	)

	define("expect_null", func():
		test("null", func(): expect_null(null))
		test("not null", func(): expect_not_null(2))
	)

class CustomContainer:
	var value: Variant
	
	func _init(p_value: Variant):
		value = p_value

	func has(p_value: Variant) -> bool:
		return value == p_value
