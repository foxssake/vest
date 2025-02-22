extends VestTestMixin

var _signal_captures := {}

# Array of [signal, recorder, is_persistent] tuples
var _signal_recorders: Array[Array] = []

func _init():
	super()
	on_case_begin.connect(func(__):
		# Remove non-persistent recorders
		_cleanup_recorders()

		# Clear captures
		_signal_captures.clear()
	)

func capture_signal(what: Signal, arg_count: int = 0, persistent: bool = false):
	# Reset captures
	_signal_captures[what] = []

	# Add listener
	var recorder = _get_signal_recorder(what, arg_count)
	if not recorder:
		push_warning("Can't capture signal with %d arguments!" % arg_count)
		return

	what.connect(recorder)
	_signal_recorders.append([what, recorder, persistent])

func get_signal_emissions(what: Signal) -> Array:
	return _signal_captures.get(what, [])

func _cleanup_recorders():
	var filtered_recorders: Array[Array] = []

	for recorder_tuple in _signal_recorders:
		var recorded_signal := recorder_tuple[0] as Signal
		var recorder := recorder_tuple[1] as Callable
		var persistent := recorder_tuple[2] as bool

		if persistent:
			filtered_recorders.append(recorder_tuple)
		else:
			recorded_signal.disconnect(recorder)

	_signal_recorders = filtered_recorders

func _get_signal_recorder(what: Signal, arg_count: int):
	match(arg_count):
		0: return func(): _record_emission(what, [])
		1: return func(a1): _record_emission(what, [a1])
		2: return func(a1, a2): _record_emission(what, [a1, a2])
		3: return func(a1, a2, a3): _record_emission(what, [a1, a2, a3])
		4: return func(a1, a2, a3, a4): _record_emission(what, [a1, a2, a3, a4])
		5: return func(a1, a2, a3, a4, a5): _record_emission(what, [a1, a2, a3, a4, a5])
		6: return func(a1, a2, a3, a4, a5, a6): _record_emission(what, [a1, a2, a3, a4, a5, a6])
		7: return func(a1, a2, a3, a4, a5, a6, a7): _record_emission(what, [a1, a2, a3, a4, a5, a6, a7])
		8: return func(a1, a2, a3, a4, a5, a6, a7, a8): _record_emission(what, [a1, a2, a3, a4, a5, a6, a7, a8])
		_: return null

func _record_emission(what: Signal, args: Array):
	if not _signal_captures.has(what):
		_signal_captures[what] = []
	_signal_captures[what].append(args)
