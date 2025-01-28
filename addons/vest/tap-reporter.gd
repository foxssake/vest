extends Object
class_name TAPReporter

static func report(results: Array[VestRunner.RunResult]) -> String:
	var lines := PackedStringArray()

	# TODO: Subtests
	lines.append("TAP version 14")
	lines.append("1..%d" % [results.size()])

	for i in range(results.size()):
		var test_id = 1 + i
		var result := results[i]

		if result.result.status == VestResult.TEST_PASS:
			lines.append("ok %d - %s" % [test_id, result.case.description])
		else:
			var yaml_data = {
				"severity": get_severity_string(result.result.status),
				"assert_source": result.result.assert_file,
				"assert_line": result.result.assert_line
			}

			if result.result.message: yaml_data["message"] = result.result.message
			if result.result.data: yaml_data["data"] = result.result.data

			lines.append("not ok %d - %s" % [test_id, result.case.description])
			lines.append("  ---")
			lines.append(YAMLWriter.stringify(yaml_data, 2))
			lines.append("  ...")

	return "\n".join(lines)

static func get_severity_string(result_status: int) -> String:
	match result_status:
		VestResult.TEST_PASS: return "pass"
		VestResult.TEST_SKIP: return "skip"
		VestResult.TEST_TODO: return "todo"
		_: return "fail"
