extends VestTest
class_name SignalsTest

signal on_something(data: String)

func test_signal_capture():
	capture_signal(on_something, 1)

	on_something.emit("foo")
	on_something.emit("bar")
	on_something.emit("baz")

	expect_equal(get_signal_emissions(on_something), [["foo"], ["bar"], ["baz"]])
