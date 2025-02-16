# Parameterized tests

Parameterized tests enable running the same test multiple times, but with
different parameters. This is useful when the test cases themselves are very
similar, and differ only in a few key values.

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Parameterized tests"

    func suite():
      var cases := [
        ["simple", "Simple"],
        ["two_words", "Two Words"],
        ["camelCase", "Camel Case"]
      ]

      for i in range(cases.size()):
        test("Capitalize #" + str(i+1), func():
          expect_equal(cases[i][0].capitalize(), cases[i][1])
        )
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Parameterized tests"

    func provide_capitalize_params() -> Array:
      return [
        ["simple", "Simple"],
        ["two_words", "Two Words"],
        ["camelCase", "Camel Case"]
      ]

    func test_capitalize(input: String, expected: String, _params="provide_capitalize_params"):
      expect_equal(input.capitalize(), expected)

    ```

## With define

Using `define()` style for test cases gives you full control on how you define
your tests - including doing so procedurally. Simply looping through the test
case data and calling `test()` will run the test case multiple times, with
different parameters.

## With methods

*Vest* will recognize tests with a single default parameter as parameterized
tests. The default parameter's value must be a method name. The method must
return an array of arrays. Each individual array will be used as parameters for
the test case.

The default parameter can have any arbitrary name, as long as its value points
to a valid method name.
