extends SceneTree

class Params:
	var run_file: String = ""
	var run_glob: String = "res://*.test.gd"
	var report_format: String = ""
	var report_file: String = ""
	var host: String = ""
	var port: int = -1

	func validate() -> Array[String]:
		var result: Array[String] = []
		if not run_file and not run_glob:
			result.append("No tests specified!")
		if report_format not in ["", "tap"]:
			result.append("Unknown report format \"%s\"!" % report_format)
		if port != -1 and port < 0 or port > 65535:
			result.append("Specified port %d is invalid!" % port)
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
			elif arg == "--vest-port":
				result.port = val.to_int()
			elif arg == "--vest-host":
				result.host = val

		return result

func _init():
	Vest._register_scene_tree(self)

	var params := Params.parse(OS.get_cmdline_args())
	var validation_errors := params.validate()
	if not validation_errors.is_empty():
		for error in validation_errors:
			push_error(validation_errors)
		quit(1)
		return

	var results := _run_tests(params)
	_report(params, results)
	await _send_results_over_network(params, results)

	if results.get_aggregate_status() == VestResult.TEST_PASS:
		print_rich("All tests [color=green]passed[/color]!")
		quit(0)
	else:
		push_error("There are test failures!")
		quit(1)

func _run_tests(params: Params) -> VestResult.Suite:
	var runner := VestLocalRunner.new()
	root.add_child(runner)

	var results: VestResult.Suite
	if params.run_file:
		results = runner.run_script_at(params.run_file)
	elif params.run_glob:
		results = runner.run_glob(params.run_glob)

	runner.free()

	return results

func _report(params: Params, results: VestResult.Suite):
	var report := TAPReporter.report(results)

	if params.report_format:
		if params.report_file in ["", "-"]:
			print(report)
		else:
			var fa := FileAccess.open(params.report_file, FileAccess.WRITE)
			fa.store_string(report)
			fa.close()

func _send_results_over_network(params: Params, results: VestResult.Suite):
	if not params.host and params.port == -1:
		return

	var host := params.host
	var port := params.port

	if not host: host = "0.0.0.0"
	if port == -1: port = 54932

	var peer := StreamPeerTCP.new()
	var err := peer.connect_to_host("0.0.0.0", port)
	if err != OK:
		push_warning("Couldn't connect on port %d! %s" % [port, error_string(err)])
		return

	await Vest.until(func(): return peer.get_status() != StreamPeerTCP.STATUS_CONNECTING)
	if peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		push_warning("Connection timed out! Socket status: %d" % [peer.get_status()])
		return

	peer.put_var(results._to_wire(), true)
	peer.disconnect_from_host()
