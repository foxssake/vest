extends RefCounted
class_name VestResult

# Result enums
enum {
	TEST_TODO,
	TEST_FAIL,
	TEST_SKIP,
	TEST_PASS
}

var status: int = TEST_TODO
var message: String = ""
var data: Dictionary = {}

var assert_file: String = ""
var assert_line: int = -1
