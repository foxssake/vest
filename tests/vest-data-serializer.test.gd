extends VestTest

func get_suite_name():
	return "VestDataSerializer"

func suite():
	var cases := [
		["bool", true, true],
		["int", 782, 782],
		["float", 78.2, 78.2],
		["string", "foo", "foo"],
		["vector", Vector3.ONE, "(1, 1, 1)"],
		["color", Color.RED, "(1, 0, 0, 1)"],
		["array", ["foo", Vector3.ONE], ["foo", "(1, 1, 1)"]],
		["PackedByteArray", PackedByteArray([1, 75, 3]), [1, 75, 3]],
		["object", SerializableObject.of(2), { "value": 2 }],
		["dictionary", { Vector3.ONE: SerializableObject.of(2) }, { "(1, 1, 1)": { "value": 2 } }],
		["nested",
			{ "foo": SerializableObject.of([1, SerializableObject.of(2)]) },
			{ "foo": { "value": [1, { "value": 2 }] } }
		]
	]

	for case in cases:
		var name := case[0] as String
		var to_serialize = case[1]
		var expected = case[2]

		test(name.capitalize(), func():
			expect_equal(Vest.__.Serializer.serialize(to_serialize), expected)
		)

class SerializableObject:
	var _value: Variant

	static func of(p_value: Variant) -> SerializableObject:
		return SerializableObject.new(p_value)

	func _init(p_value: Variant):
		_value = p_value

	func _to_vest():
		return { "value": _value }
