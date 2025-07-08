extends VestTest

func get_suite_name():
	return "VestDataSerializer"

func suite():
	var ref_a := SerializableObject.of(1)
	var ref_b := SerializableObject.of(ref_a)
	ref_a._value = ref_b

	var cases := [
		["bool", true, true],
		["int", 782, 782],
		["float", 78.2, 78.2],
		["string", "foo", "foo"],
		["array", ["foo", [1, 2]], ["foo", [1, 2]]],
		["vector", Vector3.ONE, [1., 1., 1.]],
		["color", Color.RED, [1., 0., 0., 1.]],
		["basis", Basis.FLIP_X, [[-1., 0., 0.], [0., 1., 0.], [0., 0., 1.]]],
		["PackedByteArray", PackedByteArray([1, 75, 3]), [1, 75, 3]],
		["serializable object", SerializableObject.of(2), { "value": 2 }],
		["object", UnknownObject.of(2), { "_value": 2 }],
		["dictionary", { Vector3i.ONE: SerializableObject.of(2) }, { [1, 1, 1]: { "value": 2 } }],
		["nested",
			{ "foo": SerializableObject.of([1, SerializableObject.of(2)]) },
			{ "foo": { "value": [1, { "value": 2 }] } }
		],
		["circular reference", ref_a, { "value": { "value": { "value": { "value": "SerializableObject" }}}}],
		["null", null, null]
	]

	for case in cases:
		var name := case[0] as String
		var to_serialize = case[1]
		var expected = case[2]

		test(name.capitalize(), func():
			expect_equal(Vest.__.Serializer.serialize(to_serialize, 8), expected)
		)

class SerializableObject:
	var _value: Variant

	static func of(p_value: Variant) -> SerializableObject:
		return SerializableObject.new(p_value)

	func _init(p_value: Variant):
		_value = p_value

	func _to_vest():
		return { "value": _value }

	func _to_string() -> String:
		return "SerializableObject"

class UnknownObject:
	var _value: Variant

	static func of(p_value: Variant) -> UnknownObject:
		return UnknownObject.new(p_value)

	func _init(p_value: Variant):
		_value = p_value

	func _to_string() -> String:
		return "UnknownObject"
