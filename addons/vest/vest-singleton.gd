extends Object
class_name Vest

static var _messages: Array[String] = []

static func print(message: String):
	_messages.append(message)

static func _clear_messages():
	_messages.clear()

static func _get_messages() -> Array[String]:
	return _messages.duplicate()
