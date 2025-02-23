extends VestTest

func get_suite_name() -> String:
	return "Equality"

func suite():
	test("Arrays should be equal", func():
		expect_equal([1, 2, 3], [1, 2] + [3])
	)

	test("Arrays should differ", func():
		expect_not_equal([1, 2, 3], [1, 2] + [5])
	)

	test("Dictionaries should be equal", func():
		var a := { "a": 1, "b": 2 }
		var b := { }
		b.merge(a)

		expect_equal(a, b)
	)

	test("Dictionaries should differ", func():
		expect_not_equal({ "a": 1 }, { "b": 2 })
	)

	test("Should equal on custom method", func():
		expect_equal(CustomEquals.new(1), CustomEquals.new(1))
	)

	test("Should differ on custom method", func():
		expect_not_equal(CustomEquals.new(1), CustomEquals.new(2))
	)

class CustomEquals:
	var value

	func _init(p_value):
		value = p_value

	func equals(other: CustomEquals):
		return value == other.value
