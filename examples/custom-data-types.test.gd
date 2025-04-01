extends VestTest

func get_suite_name():
	return "Custom data types"

func test_custom_type():
	var a := CustomData.new(2)
	var b := CustomData.new("foo")

	# Test report will contain a proper representation, instead of RefData<#...>
	expect_equal(a, b)

class CustomData:
	var _value: Variant

	func _init(p_value: Variant):
		_value = p_value

	func _to_vest():
		return { "value": _value }
