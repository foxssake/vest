# Assertions

The point of testing is to perform some operation, and then validate
requirements about the results. This latter part is done using *assertions*:

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "pow()"

    func suite():
      test("exp 0 should return 1", func():
        expect_equal(1, pow(128, 0))
      )
      test("exp 1 should return input", func():
        expect_equal(128, pow(128, 128))
      )
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "pow()"

    func test_exp_0_should_return_1():
      expect_equal(1, pow(128, 0))

    func test_exp_1_should_return_inpt():
      expect_equal(128, pow(128, 128))
    ```

The example above contains multiple *assertions* about the results of the
`pow()` function. If all the assertions succeed in a test case, it is
considered *passing*. If any of the assertions fail, the test case is also
considered *failing*.

Checking for equality is not the only available assertion.

## Assert methods

*Vest* provides different assertion methods. Each of them take an additional
message as the last parameter, that may be used as hints if the assertion
fails.

`expect(condition)`, `expect_not(conditions)`
:   Asserts that the given condition is true, fails the test otherwise. Has a
    negated version for asserting that the given condition is false. As these
    assertions are very general, it is a good practice to include a message.

    Prefer more specific assert methods, as they can include more relevant data
    in the test report.

    ```gdscript
    expect_not(array.is_empty(), 'Array was not empty!')
    expect(array.size() == 3, 'Array size not as expected!')
    ```

`expect_equal(), expect_not_equal()`
:   Asserts that two values are equal. Uses Godot's builtin `==` operator. If
    the values being compared are objects implementing an `equals()` method, the
    method will be used instead.

    In case the assertion fails, both values will be included in the report, to
    help with debugging.

    Has a negated version to assert that two values are different.

    ```gdscript
    expect_equal("ba" + "na".repeat(2), "banana")
    expect_not_equal(2 * 2, 5)
    ```

`expect_true(), expect_false()`
:   Synonyms of `expect()` and `expect_not()`. Aimed at better readability for
    asserting on boolean values.

`expect_empty()`
:   Asserts that a given container is empty. Godot's built-in types and objects
    implementing `is_empty()` are supported.

    If the assertion fails, the container will be included in the report.

    ```gdscript
    expect_empty(range(1,1))
    ```

`expect_contains()`
:   Asserts that a given container includes a value. Godot built-in types and
    objects implementing `has()` are supported.

    If the assertion fails, the container will be included in the report.

    ```gdscript
    expect_contains(range(0, 5), 3)
    ```
