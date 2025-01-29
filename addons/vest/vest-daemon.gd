extends SceneTree

var port := 0
var file := ""

func _init():
	_parse_cmdline()
	var results := _run_tests()
	_send_results(results)

	quit(0)

func _parse_cmdline():
	var args := OS.get_cmdline_args()
	for i in range(args.size()):
		var arg = args[i]

		if arg == "--vest-port":
			port = int(args[i+1])
		elif arg == "--vest-file":
			file = args[i+1]

func _run_tests() -> VestResult.Suite:
	var runner := VestRunner.new()
	root.add_child(runner)

	var results := runner.run_script_at(file)

	runner.free()

	return results

func _send_results(results: VestResult.Suite):
	var peer := StreamPeerTCP.new()
	var err := peer.connect_to_host("0.0.0.0", port)
	if err != OK:
		OS.alert("Couldn't connect on port %d! %s" % [port, error_string(err)])
		return

	_await(func():
		peer.poll()
		return peer.get_status() != StreamPeerTCP.STATUS_CONNECTING
		, 4.)
	if peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		OS.alert("Connection timed out! Socket status: %d" % [peer.get_status()])
		return

	if results:
		peer.put_utf8_string(TAPReporter.report(results))
	else:
		peer.put_utf8_string("<invalid script!>")

	peer.disconnect_from_host()

func _await(condition: Callable, timeout: float = 8., interval: float = .2) -> Error:
	while timeout > 0.:
		if condition.call():
			return OK

		OS.delay_msec(interval * 1000)
		timeout -= interval
	return ERR_TIMEOUT
