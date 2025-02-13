extends "res://addons/vest/runner/vest-base-runner.gd"
class_name VestDaemonRunner

var _server: TCPServer
var _port: int
var _peer: StreamPeerTCP

func run_instance(instance: VestTest) -> VestResult.Suite:
	return await run_script(instance.get_script() as Script)

func run_script(script: Script) -> VestResult.Suite:
	var params := VestCLI.Params.new()
	params.run_file = script.resource_path

	return await _run_with_params(params)

func run_glob(glob: String) -> VestResult.Suite:
	var params := VestCLI.Params.new()
	params.run_glob = glob

	return await _run_with_params(params)

func _run_with_params(params: VestCLI.Params) -> VestResult.Suite:
	# Start host
	if _start() != OK:
		push_error("Couldn't start vest host!")
		return null

	# Start process
	params.host = "0.0.0.0"
	params.port = _port
	var pid := VestCLI.run(params)

	# Wait for agent to connect
	if await Vest.until(func(): return _server.is_connection_available()) != OK:
		push_error("Agent didn't connect in time!")
		return null

	_peer = _server.take_connection()

	# Take results
	# TODO: Configurable timeouts
	if await Vest.until(func(): return _peer.get_available_bytes() > 0) != OK:
		push_error("Didn't receive results in time! Available bytes: %d" % [_peer.get_available_bytes()])
		_stop()
		return null

	var results = _peer.get_var(true)
	_stop()

	if results == null:
		push_error("Test run failed!")
		return null
	elif results is Dictionary:
		var suite_result = VestResult.Suite._from_wire(results)
		return suite_result
	else:
		push_error("Unrecognized test result data! %s" % [results])
		return null

func _start(port: int = -1):
	# Start host
	_server = TCPServer.new()

	# Find random port for host
	if port < 0:
		for i in range(32):
			port = randi_range(49152, 65535)
			if _server.listen(port) == OK:
				break
	else:
		_server.listen(port)
	_port = port

	if not _server.is_listening():
		push_error("Failed to find available port!")
		return ERR_CANT_CREATE

	return OK

func _stop():
	_peer.disconnect_from_host()
	_server.stop()

	_peer = null
	_server = null
	_port = -1
