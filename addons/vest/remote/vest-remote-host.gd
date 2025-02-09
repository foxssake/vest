extends "res://addons/vest/runner/vest-base-runner.gd"
class_name VestRemoteHost

var _server: TCPServer
var _port: int
var _peer: StreamPeerTCP

func run_script(script: Script) -> VestResult.Suite:
	if not _server or not _server.is_listening():
		print("Server is not listening!")
		return null

	_peer.put_var({
		"cmd": "file",
		"file": script.resource_path
	})
	return await await_results()

func run_glob(glob: String) -> VestResult.Suite:
	if not _server or not _server.is_listening():
		print("Server is not listening!")
		return null

	_peer.put_var({
		"cmd": "glob",
		"glob": glob
	})
	return await await_results()

func start(port: int = -1) -> Error:
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

func get_port() -> int:
	return _port

func await_client(timeout: float = 8., interval: float = 0.2) -> Error:
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

func await_results(timeout: float = 8., interval: float = 0.2) -> VestResult.Suite:
	while timeout > 0.:
		if _peer.get_available_bytes() > 0:
			break
		await get_tree().create_timer(interval).timeout
		timeout -= interval

	var serialized_results := _peer.get_var()
	if not serialized_results is Dictionary:
		return null

	return VestResult.Suite._from_wire(serialized_results)

func stop():
	_peer.disconnect_from_host()
	_server.stop()

	_peer = null
	_server = null
	_port = -1
