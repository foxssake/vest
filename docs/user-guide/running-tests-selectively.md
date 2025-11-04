# Running tests selectively

In certain cases, you only want to run a few select tests. This can be useful
when trying to fix a specific test failure. With the focus being on one or few
cases, it makes sense to only run those.

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Your first test"

    func suite():
      test_only("Addition", func():
        expect_equal(2 + 2, 5)
      )

      test("Subtraction", func():
        # This won't run
        expect_equal(5 - 3, 2)
      )
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Your first test"

    func test_addition__only():
      expect_equal(2 + 2, 4)

    func test_subtraction():
      # This won't run
      expect_equal(5 - 3, 2)
    ```

## Specifying tests

To run only a select set of tests, mark them with `only`. To define them, use
`define_only()` and `test_only()`. Both of these work the same as their regular
counterparts, with the difference that they mark their definitions for
selective running.

If a complete test suite is marked as `only` with `define_only()`, each of its
test cases and subsuites will run.

For test methods, add the `__only` suffix to the method name. The suffix is
chosen so it doesn't shadow otherwise legitimate test case names.

## Running the selected tests

When [running from the editor], *vest* automatically detects if there's any
tests marked as `only`. If yes, then only those will be ran. If no tests are
marked, all tests will be ran.

When [running from CLI], *vest* defaults to ignoring the marks and runs all the
tests. This is to make sure that all tests [run in CI], unless otherwise
specified. This can be overridden with [command line flags].


[running from the editor]: ./running-from-ui.md
[running from CLI]: ./running-from-cli.md
[run in CI]: ./running-on-ci.md
[command line flags]: ./running-from-cli.md#command-line-parameters
