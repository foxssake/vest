extends SceneTree

class Params:
	var run_file: String = ""
	var run_glob: String = "res://*.test.gd"
	var report_format: String = ""
	var report_file: String = ""

	func validate() -> Array[String]:
		var result: Array[String] = []
		if not run_file and not run_glob:
			result.append("No tests specified!")
		if report_format not in ["", "tap"]:
			result.append("Unknown report format \"%s\"!" % report_format)
		return result

	static func parse(args: Array[String]) -> Params:
		var result := Params.new()

		for i in range(args.size()):
			var arg := args[i]
			var val := args[i+1] if i+1 < args.size() else ""

			if arg == "--vest-file":
				result.run_file = val
			elif arg == "--vest-glob":
				result.run_glob = val
			elif arg == "--vest-report-file":
				result.report_file = val
			elif arg == "--vest-report-format":
				result.report_format = val

		return result

func _init():
	var params := Params.parse(OS.get_cmdline_args())
	var validation_errors := params.validate()
	if not validation_errors.is_empty():
		for error in validation_errors:
			push_error(validation_errors)
		quit(1)
		return

	var runner := VestLocalRunner.new()
	root.add_child(runner)

	var results: VestResult.Suite
	if params.run_file:
		results = runner.run_script_at(params.run_file)
	elif params.run_glob:
		results = runner.run_glob(params.run_glob)

	runner.free()

	var report := TAPReporter.report(results)
	print(report)

	if params.report_file and params.report_format:
		var fa := FileAccess.open(params.report_file, FileAccess.WRITE)
		fa.store_string(report)
		fa.close()

	quit(0)
