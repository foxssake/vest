extends "res://addons/vest/runner/vest-base-runner.gd"
class_name VestDaemonRunner

var _server: TCPServer
var _port: int
var _peer: StreamPeerTCP

func run_instance(instance: VestTest) -> VestResult.Suite:
	return await run_script(instance.get_script() as Script)

func run_script(script: Script) -> VestResult.Suite:
	return await _run_with_args(["--vest-script", script.resource_path])

func run_glob(glob: String) -> VestResult.Suite:
	return await _run_with_args(["--vest-glob", glob])

func _run_with_args(args: Array[String]) -> VestResult.Suite:
	# Start host
	if _start() != OK:
		push_error("Couldn't start vest host!")
		return null

	# Start process
	var instance_args = [
		"--headless",
		"-s", "res://addons/vest/daemon/vest-daemon.gd",
		"--vest-port", _port
	] + args
	var pid := OS.create_instance(instance_args)
	print("Started process %d, listening on port %d, with args %s" % [pid, _port, instance_args])

	# Wait for agent to connect
	if await _await_agent() != OK:
		push_error("Vest agent didn't connect!")
		return null

	# Take results
	# TODO: Configurable timeouts
	print("Waiting for results...")
	for i in range(32):
		if _peer.get_available_bytes() > 0:
			break
		await get_tree().create_timer(0.2).timeout

	var results = _peer.get_var()
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
		print("Failed to find available port!")
		return ERR_CANT_CREATE

	return OK

func _await_agent(timeout: float = 8., interval: float = 0.2) -> Error:
	if not _server or not _server.is_listening():
		print("Server is not listening!")
		return ERR_UNCONFIGURED

	# Listen for connection
	print("Waiting for incoming connection...")
	while timeout > 0.:
		if _server.is_connection_available():
			break

		await get_tree().create_timer(interval).timeout
		timeout -= interval

	if not _server.is_connection_available():
		print("Timeout!")
		return ERR_TIMEOUT

	_peer = _server.take_connection()
	return OK

func _stop():
	_peer.disconnect_from_host()
	_server.stop()

	_peer = null
	_server = null
	_port = -1
