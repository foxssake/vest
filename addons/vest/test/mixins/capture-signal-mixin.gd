extends VestTestMixin

var _signal_captures := {}

func capture_signal(what: Signal, arg_count: int = 0):
	# Reset captures
	_signal_captures[what] = []

	# Add listener
	match(arg_count):
		0: what.connect(func(): _record_emission(what, []))
		1: what.connect(func(a1): _record_emission(what, [a1]))
		2: what.connect(func(a1, a2): _record_emission(what, [a1, a2]))
		3: what.connect(func(a1, a2, a3): _record_emission(what, [a1, a2, a3]))
		4: what.connect(func(a1, a2, a3, a4): _record_emission(what, [a1, a2, a3, a4]))
		5: what.connect(func(a1, a2, a3, a4, a5): _record_emission(what, [a1, a2, a3, a4, a5]))
		6: what.connect(func(a1, a2, a3, a4, a5, a6): _record_emission(what, [a1, a2, a3, a4, a5, a6]))
		7: what.connect(func(a1, a2, a3, a4, a5, a6, a7): _record_emission(what, [a1, a2, a3, a4, a5, a6, a7]))
		8: what.connect(func(a1, a2, a3, a4, a5, a6, a7, a8): _record_emission(what, [a1, a2, a3, a4, a5, a6, a7, a8]))
		_: push_warning("Can't capture signal with %d arguments!" % arg_count)

func get_signal_emissions(what: Signal) -> Array:
	return _signal_captures.get(what, [])

func _record_emission(what: Signal, args: Array):
	if not _signal_captures.has(what):
		_signal_captures[what] = []
	_signal_captures[what].append(args)
