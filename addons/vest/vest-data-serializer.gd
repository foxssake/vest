extends Object

static func serialize(data: Variant) -> Variant:
	match typeof(data):
		# Numbers
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT:
			return data

		# Strings
		TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH:
			return str(data)

		# Linalg
		TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_RECT2, TYPE_RECT2I, \
		TYPE_VECTOR3, TYPE_VECTOR3I, TYPE_VECTOR4, TYPE_VECTOR4I, \
		TYPE_PLANE, TYPE_QUATERNION:
			return str(data)

		TYPE_TRANSFORM2D, TYPE_TRANSFORM3D, TYPE_AABB, TYPE_BASIS, \
		TYPE_PROJECTION:
			return str(data)

		# Other
		TYPE_COLOR, TYPE_RID, TYPE_CALLABLE, TYPE_SIGNAL:
			return str(data)

		# Complex
		TYPE_OBJECT:
			var object := data as Object
			if object.has_method("_to_vest"):
				return serialize(object._to_vest())
			return str(object)

		# Arrays
		TYPE_PACKED_BYTE_ARRAY, TYPE_PACKED_INT32_ARRAY, TYPE_PACKED_INT64_ARRAY, \
		TYPE_PACKED_FLOAT32_ARRAY, TYPE_PACKED_FLOAT64_ARRAY, TYPE_PACKED_STRING_ARRAY, \
		TYPE_PACKED_VECTOR2_ARRAY, TYPE_PACKED_VECTOR3_ARRAY, TYPE_PACKED_COLOR_ARRAY:
			return serialize(Array(data))

		TYPE_ARRAY:
			var array := data as Array
			return array.map(func(it): return serialize(it))
		
		# Dictionary
		TYPE_DICTIONARY:
			var dict := data as Dictionary
			var result := {}

			for key in dict:
				var value = dict.get(key)
				result[serialize(key)] = serialize(value)
			return result

		# Default
		_: return str(data)
