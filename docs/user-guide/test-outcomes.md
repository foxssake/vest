# Test outcomes

Test cases can have different outcomes:

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Test outcomes"

    func suite():
      test("Pass", func(): ok("This test passes"))
      test("Fail", func(): fail("This test fails"))
      test("Skip", func(): skip("This test should be skipped"))
      test("TODO", func(): todo("This test is not implemented yet"))
      test("Void", func(): pass) # This test has no outcome
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Test outcomes"

    func test_pass():
      ok("This test passes")

    func test_fail():
      fail("This test fails")

    func test_skip():
      skip("This test should be skipped")

    func test_todo():
      todo("This test is not implemented yet")

    func test_void():
      # This test has no outcome
      pass
    ```

Pass
:   All requirements are fulfilled, the test subject works as expected.

Fail
:   Some or all of the requirements are broken, the test subject doesn't work as
    expected.

Skip
:   The test has skipped validating requirements. Often used for temporarily
    disabling tests.

TODO
:   The test is yet to be implemented.

Void
:   No assertions have been made. Usually happens with empty test methods, or if
    the test ran into an engine-level issue ( e.g. syntax- or runtime errors )

The recommended way to set outcomes is to use [assertions](./assertions.md).
