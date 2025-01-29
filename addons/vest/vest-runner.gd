extends Node
class_name VestRunner

class RunResult:
	var suite: VestSuite
	var case: VestCase
	var result: VestResult

	static func of(p_suite: VestSuite, p_case: VestCase, p_result: VestResult) -> RunResult:
		var result := RunResult.new()
		result.suite = p_suite
		result.case = p_case
		result.result = p_result

		return result

	func _to_string() -> String:
		return "RunResult(suite=%s, case=%s, result=%s)" % [suite.name, case, result]

func run_case(suite: VestSuite, case: VestCase) -> VestResult.Case:
	var test_instance := suite._owner
	test_instance._prepare_for_case(case)

	case.callback.call()
	return test_instance._get_result()

func run_suite(suite: VestSuite) -> VestResult.Suite:
	var result := VestResult.Suite.new()
	result.suite = suite

	for subsuite in suite.suites:
		result.subsuites.append(run_suite(subsuite))

	for case in suite.cases:
		result.cases.append(run_case(suite, case))

	return result

func run_instance(instance: VestTest) -> VestResult.Suite:
	return run_suite(instance._get_suite())

func run_script_at(path: String) -> VestResult.Suite:
	var test_script := load(path)

	if not test_script or not test_script is Script:
		return null

	var test_instance = test_script.new()
	if not test_instance is VestTest:
		return null

	return run_instance(test_instance)

func run_in_background(instance: VestTest):
	# Start host
	var port = 16384
	var server := TCPServer.new()

	# Find random port for host
	for i in range(32):
		port = randi_range(49152, 65535)
		if server.listen(port) == OK:
			break
	if not server.is_listening():
		print("Failed to find available port!")
		return

	# Start process
	var pid := OS.create_instance([
		"--headless", "-s", "res://addons/vest/vest-daemon.gd",
		"--vest-port", port,
		"--vest-file", instance.get_script().resource_path
	])
	print("Started process %d" % [pid])

	# Listen for connection
	print("Waiting for incoming connection...")
	for i in range(32):
		if server.is_connection_available():
			break
		await get_tree().create_timer(0.2).timeout

	if not server.is_connection_available():
		print("Timeout!")
		server.stop()
		return

	var peer := server.take_connection()

	# Take results
	print("Waiting for results...")
	for i in range(32):
		if peer.get_available_bytes() > 0:
			break
		await get_tree().create_timer(0.2).timeout

	var results := peer.get_utf8_string()

	print(results)

	peer.disconnect_from_host()
	server.stop()

#	print("Waiting before killing %d" % [pid])
#	await get_tree().create_timer(1.).timeout
#
#	print("Killing process %d" % [pid])
#	OS.kill(pid)
