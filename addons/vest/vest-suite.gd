extends RefCounted
class_name VestSuite

var name: String = ""
var cases: Array[VestCase] = []

func _to_string() -> String:
	return "VestSuite(name=\"%s\", cases=%s)" % [name, cases]
