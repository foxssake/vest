# Capturing signals

*Vest* lets you capture signal emissions. This is useful when a requirement is
that certain signals are emitted, or even signals *not* being emitted.

=== "define()"
    ```gdscript
    extends VestTest

    signal on_event(data: String)

    func get_suite_name() -> String:
      return "Signals test"

    func before_all():
      capture_signal(on_event, 1, true)

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
    ```
=== "methods"
    ```gdscript
    extends VestTest

    signal on_event(data: String)

    func get_suite_name() -> String:
      return "Signals test"

    func before_all():
      capture_signal(on_event, 1, true)

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
    ```

## Capture

By calling `capture_signal()`, a listener is connected to the signal that will
record each emission. Make sure to pass in the amount of parameters the signal
has, otherwise *vest* may fail at recording emissions.

*vest* has *persistent* and *non-persistent* signal captures. The latter,
*non-persistent* captures are disconnected after every test case. If you want
to call `capture_signal()` only once and have it be active for all subsequent
test cases in the suite, pass in `true` for its *persistent* parameter.

Persistent captures enable you to setup all the signal captures in
`before_all()` or `on_begin()`, instead of having to repeat the same call for
all your test cases.

!!!note
    All captured signal emissions are reset before each test case. This so that
    a signal emission captured in test A doesn't affect the results of test B.

## Inspect

To retrieve the recorded emissions, call `get_signal_emissions()` with the
captured signal. It will return an array of arrays, where each individual array
is the list of parameters that were emitted.

!!!tip
    Since `get_signal_emissions()` returns an array, it can also be asserted as
    such. This means that the [assert library] can be used, instead of having
    to resort to special methods or systems.


[assert library]: ./assertions.md
