extends RefCounted
class_name VestResult

# Result enums
enum {
	TEST_VOID,
	TEST_TODO,
	TEST_FAIL,
	TEST_SKIP,
	TEST_PASS
}

var status: int = TEST_VOID
var message: String = ""
var data: Dictionary = {}

# TODO: Support assert locations
var assert_file: String = ""
var assert_line: int = -1

static func get_status_string(p_status: int) -> String:
	match p_status:
		TEST_VOID: return "VOID"
		TEST_TODO: return "TODO"
		TEST_FAIL: return "FAIL"
		TEST_SKIP: return "SKIP"
		TEST_PASS: return "PASS"
		_: return "?"

func _to_string() -> String:
	return "VestResult(status=%s, message=\"%s\", data=%s, assert_loc=\"%s\":%d)" % [
		get_status_string(status), message, data, assert_file, assert_line
	]
