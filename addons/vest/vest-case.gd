extends RefCounted
class_name VestCase

# Result enums
enum {
	TEST_TODO,
	TEST_FAIL,
	TEST_SKIP,
	TEST_PASS
}

var description: String = ""
var callback: Callable

var definition_file: String = ""
var definition_line: int = -1

func _to_string() -> String:
	return "VestCase(\"%s\")" % description
