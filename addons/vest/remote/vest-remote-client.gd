extends Node
class_name VestRemoteClient

var _peer: StreamPeerTCP
var _runner: VestLocalRunner

func connect_to_host(port: int, host: String = "0.0.0.0") -> Error:
	# Connect to host
	_peer = StreamPeerTCP.new()
	var err := _peer.connect_to_host(host, port)
	if err != OK:
		push_warning("Couldn't connect on port %d! %s" % [port, error_string(err)])
		return err

	# Wait for peer to finish connecting
	var timeout := 8.
	var interval := 0.2
	while timeout > 0.:
		if _peer.get_status() != StreamPeerTCP.STATUS_CONNECTING:
			break
		await get_tree().create_timer(interval).timeout
		timeout -= interval

	if _peer.get_status() != StreamPeerTCP.STATUS_CONNECTED:
		push_warning("Connection timed out! Socket status: %d" % [_peer.get_status()])
		return ERR_TIMEOUT

	return OK

func poll_commands(timeout: float = 8.0, interval: float = 0.2) -> Error:
	while timeout > 0.:
		_peer.poll()
		if _peer.get_available_bytes() > 0:
			break
		await get_tree().create_timer(interval).timeout
		timeout -= interval
	
	if _peer.get_available_bytes() <= 0:
		return ERR_TIMEOUT

	var command := _peer.get_var() as Dictionary

	_runner = VestLocalRunner.new()
	add_child(_runner)

	match command["cmd"]:
		"file":
			var results := await _runner.run_script_at(command["file"])
			_peer.put_var(results._to_wire())
			return OK
		"glob":
			var results := await _runner.run_glob(command["glob"])
			_peer.put_var(results._to_wire())
			return OK
		_:
			push_error("Unknown runner command: %s" % [command])
			return ERR_METHOD_NOT_FOUND

func disconnect_from_host():
	_peer.disconnect_from_host()
