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

		var test_point := "ok"
		if result.result.status == VestResult.TEST_FAIL:
			test_point = "not ok"

		var description := "%s %s" % [result.suite.name, result.case.description]

		var directive = ""
		match result.result.status:
			VestResult.TEST_TODO: directive = "\t# TODO"
			VestResult.TEST_SKIP: directive = "\t# SKIP"

		lines.append("%s %d - %s%s" % [test_point, test_id, description, directive])

		if result.result.status == VestResult.TEST_FAIL:
			var yaml_data = {
				"severity": "fail",
				"assert_source": result.result.assert_file,
				"assert_line": result.result.assert_line
			}

			if result.result.message: yaml_data["message"] = result.result.message
			if result.result.data: yaml_data["data"] = result.result.data

			lines.append("  ---")
			lines.append(YAMLWriter.stringify(yaml_data, 2))
			lines.append("  ...")

	return "\n".join(lines)
