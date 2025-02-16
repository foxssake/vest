# Lifecycle hooks

*Vest* provides hooks to run pieces of code during certain stages of execution.

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Lifecycle hooks test"

    func suite():
      on_begin.connect(func():
        print("Starting " + get_suite_name())
      )

      on_suite_begin.connect(func(p_suite: VestDefs.Suite):
        print("Starting suite " + p_suite.name)
      )

      on_case_begin.connect(func(case: VestDefs.Case):
        print("Starting case " + case.description)
      )

      on_case_finish.connect(func(case: VestDefs.Case):
        print("Finishing case " + case.description)
      )

      on_suite_finish.connect(func(p_suite: VestDefs.Suite):
        print("Finishing suite " + p_suite.name)
      )

      on_finish.connect(func():
        print("Finishing " + get_suite_name())
      )

      test("First test", func(): ok())
      test("Second test", func(): ok())
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Lifecycle hooks test"

    func before_all():
      print("Starting " + get_suite_name())

    func before_suite(p_suite: VestDefs.Suite):
      print("Starting suite " + p_suite.name)

    func before_case(case: VestDefs.Case):
      print("Starting case " + case.description)

    func after_case(case: VestDefs.Case):
      print("Finishing case " + case.description)

    func after_suite(p_suite: VestDefs.Suite):
      print("Finishing suite " + p_suite.name)

    func after_all():
      print("Finishing " + get_suite_name())

    func test_first():
      ok()

    func test_second():
      ok()
    ```

!!!note
    Since the example above uses `print()`, run it in debug mode to see the
    test output. For printing messages that show up in the test report, see
    [Custom messages].

## Hook methods and signals

Both signals and methods are available to hook into a test class' lifecycle.
For methods, simply define them with the right signature.

For signals, connect your handlers to them either in a `suite()` method, or in
`_init()`.

!!!warning
    Make sure to call `super()` when overriding `_init()`!

`before_all()` / `on_begin()`
:   Called before the test class is run. Useful for setting up parts of the
    test environment that all the tests rely on.

`before_suite(suite)` / `on_begin_suite(suite)`
:   Called before each test suite defined by the class. This includes the class'
    root suite, and every nested suite defined by it.

    The suite definition is passed as parameter.

`before_case(case)` / `on_begin_case(case)`
:   Called before each test case defined by the class. This includes cases in
    nested suites as well. Useful for setting up parts of the test environment
    that should be refreshed for each test case.

    The case definition is passed as parameter.

`after_case(case)` / `on_case_finish(case)`
:   Ran after each test case defined by the class, including cases in nested
    suites. Useful for cleaning up after individual test cases.

    The case definition is passed as parameter.

`after_suite(suite)` / `on_suite_finish(case)`
:   Ran after each test suite defined by the class, including nested suites.

    The suite definition is passed as parameter.

`after_all()` / `on_finish()`
:   Ran after the test class has run. Useful for cleaning up after all the
    tests have ran.

!!!tip
    Overriding methods and connecting to signals are not bound to either
    `define()` or method-based test definitions. Mix and match as they make the
    most sense for you!


[Custom messages]: ./custom-messages.md
