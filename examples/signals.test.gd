extends VestTest

signal on_event(data: String)

func get_suite_name() -> String:
	return "Signals test"

func before_all():
	capture_signal(on_event, 1)

func suite():
	test("Signal was emitted at least once", func():
		on_event.emit("foo")
		on_event.emit("bar")

		expect_not_empty(get_signal_emissions(on_event))
	)

	test("Signal was emitted just once", func():
		on_event.emit("foo")

		expect_equal(get_signal_emissions(on_event).size(), 1)
	)

	test("Signal was emitted with params", func():
		on_event.emit("foo")
		on_event.emit("bar")

		expect_contains(get_signal_emissions(on_event), ["bar"])
	)

func test_signal_was_emitted_at_least_once():
	on_event.emit("foo")
	on_event.emit("bar")

	expect_not_empty(get_signal_emissions(on_event))

func test_signal_was_emitted_just_once():
	on_event.emit("foo")

	expect_equal(get_signal_emissions(on_event).size(), 1)

func test_signal_was_emitted_with_params():
	on_event.emit("foo")
	on_event.emit("bar")

	expect_contains(get_signal_emissions(on_event), ["bar"])
