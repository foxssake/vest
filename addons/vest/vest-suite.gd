extends RefCounted
class_name VestSuite

var name: String = ""
var cases: Array[VestCase] = []
var suites: Array[VestSuite] = []

func _to_string() -> String:
	return "VestSuite(name=\"%s\", cases=%s, suites=%s)" % [name, cases, suites]
