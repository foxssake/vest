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
        expect_equal(128, pow(128, 1))
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
      expect_equal(128, pow(128, 1))
    ```

The example above contains multiple *assertions* about the results of the
`pow()` function. If all the assertions succeed in a test case, it is
considered *passing*. If any of the assertions fail, the test case is also
considered *failing*.

Checking for equality is not the only available assertion.

!!!note
    Contrary to other languages, GDScript doesn't have exceptions. This means
    that when *vest* encounters a failed assertion, the test will keep running.
    However, *vest* will record all the failed assertions.

## Expectations and assertions

There's two styles available for writing assertions - the `expect()` methods,
and the `assert_that()` fluent API.

Using expectations, each call defines a different requirement, possibly about
different values and objects.

Using `assert_that()`, an asserted value is specified, which will be the
subject of the attached assertions. The previous example rewritten to use
`assert_that()` looks as follows:

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "assert_that()"

    func suite():
      test("exp 0 should return 1", func():
        assert_that(pow(128, 0))\
          .is_not_null()\
          .is_equal_to(1)
      )
      test("exp 1 should return input", func():
        assert_that(pow(128, 1))\
          .is_not_null()\
          .is_equal_to(128)
      )
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "assert_that()"

    func test_exp_0_should_return_1():
      assert_that(pow(128, 0))\
        .is_not_null()\
        .is_equal_to(1)

    func test_exp_1_should_return_inpt():
      assert_that(pow(128, 1))\
        .is_not_null()\
        .is_equal_to(128)
    ```

Assertions in this way can be chained, making it convenient to define multiple
requirements against the same value.

The `expect()` methods and `assert_that()` are interchangeable - use
whichever makes the most sense for your test case.

## Assert methods

*Vest* provides different assertion methods. Each of them take an additional
message as the last parameter, that may be used as hints if the assertion
fails.

`expect(condition)`, `expect_not(conditions)` / `.passes(condition)`, `.fails(condition)`
:   Asserts that the given condition is true, fails the test otherwise. Has a
    negated version for asserting that the given condition is false. As these
    assertions are very general, it is a good practice to include a message.

    For `.passes()` and `.fails()`, the argument is a Callable, that receives
    the asserted value as a parameter. The Callable must return true if the
    condition is true, otherwise false.

    Prefer more specific assert methods, as they can include more relevant data
    in the test report.

    === "expect()"
        ```gdscript
        expect_not(array.is_empty(), 'Array was not empty!')
        expect(array.size() == 3, 'Array size not as expected!')
        ```
    === "assert_that()"
        ```gdscript
        assert_that(array)\
          .fails(func(it): return it.is_empty())\
          .passes(func(it): return it.size() == 3)
        ```

`expect_equal()`, `expect_not_equal()` / `.is_equal_to()`, `.is_not_equal_to()`
:   Asserts that two values are equal. Uses Godot's builtin `==` operator. If
    the values being compared are objects implementing an `equals()` method, the
    method will be used instead.

    In case the assertion fails, both values will be included in the report, to
    help with debugging.

    Supports builtin types. For custom types, *vest* will call `equals()` if it
    is implemented.

    Has a negated version to assert that two values are different.

    === "expect()"
        ```gdscript
        expect_equal("ba" + "na".repeat(2), "banana")
        expect_not_equal(2 * 2, 5)
        ```
    === "assert_that()"
        ```gdscript
        assert_that("ba" + "na".repeat(2))\
          .is_equal_to("banana")\
          .is_not_equal_to("apple")
        ```

`expect_true()`, `expect_false()` / `.passes()`, `.fails()`
:   Synonyms of `expect()` and `expect_not()`. Aimed at better readability for
    asserting on boolean values.

`expect_empty()`, `expect_not_empty()` / `.is_empty()`, `.is_not_empty()`
:   Asserts that a given container is empty. Godot's built-in types and objects
    implementing `is_empty()` are supported. Has a negated version.

    Supports builtin types. For custom types, *vest* will call `is_empty()` if it
    is implemented.

    If the assertion fails, the container will be included in the report.

    === "expect()"
        ```gdscript
        expect_empty(range(1, 1))
        expect_not_empty(range(1, 8))
        ```
    === "assert_that()"
        ```gdscript
        assert_that(range(1, 1)).is_empty()
        assert_that(range(1, 8)).is_not_empty()
        ```

`expect_contains()`, `expect_does_not_contain()` / `.contains()`, `.does_not_contain()`
:   Asserts that a given container includes a value. Godot built-in types and
    objects implementing `has()` are supported. Has a negated version.

    Supports builtin types. For custom types, *vest* will call `has()` if it
    is implemented.

    If the assertion fails, the container will be included in the report.

    === "expect()"
        ```gdscript
        expect_contains(range(0, 5), 3)
        expect_does_not_contain(range(2, 4), 4)
        ```
    === "assert_that()"
        ```gdscript
        assert_that(range(0, 5))\
          .contains(3)\
          .does_not_contain(7)
        ```

`expect_null()`, `expect_not_null()` / `.is_null()`, `.is_not_null()`
:   Asserts that a given value is null. Has a negated version.

    If the assertion fails, the container will be included in the report.

    === "expect()"
        ```gdscript
        var data := { "foo": 2 }
        expect_null(data.get("bar"))
        expect_not_null(data.get("foo"))
        ```
    === "assert_that()"
        ```gdscript
        var data := { "foo": 2 }
        assert_that(data.get("bar")).is_null()
        assert_that(data.get("foo")).is_not_null()
        ```
