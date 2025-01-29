extends RefCounted
class_name VestSuite

var name: String = ""
var cases: Array[VestCase] = []
var suites: Array[VestSuite] = []

var _owner: VestTest

func _to_string() -> String:
	return "VestSuite(name=\"%s\", cases=%s, suites=%s)" % [name, cases, suites]

func _to_wire() -> Dictionary:
	return { "name": name }

static func _from_wire(data: Dictionary) -> VestSuite:
	var result := VestSuite.new()
	result.name = data["name"]
	return result
