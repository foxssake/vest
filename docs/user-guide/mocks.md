# Mocks

A common practice is to break down complex behavior into multiple cooperating
classes. When unit testing a class, we don't want to test its dependencies too,
so instead we introduce [test doubles].

*Vest* provides *mocks* for this purpose. Mocks are objects that implement the
same methods as the original class, but allow you to specify what is returned
and when. In addition, mocks record their method calls, so you can validate
whether a method was called and with what parameters.

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Mocks"

    var simple_math: SimpleMath

    func suite():
      on_case_begin.connect(func(__):
        simple_math = mock(SimpleMath)

        # Specify default answers
        when(simple_math.times).then_return(0)
        when(simple_math.sum).then_return(0)
      )

      test("Return configured answer", func():
        when(simple_math.times).with_args([2.0, 2.0]).then_return(5)
        expect_equal(simple_math.times(2, 2), 5)
      )

      test("Method was called at least once", func():
        simple_math.times(4, 4)

        var calls := get_calls_of(simple_math.times)
        expect(not calls.is_empty(), "Method was not called!")
      )

      test("Method was called with parameters", func():
        simple_math.times(2, 4)
        expect_contains(get_calls_of(simple_math.times), [2.0, 4.0])
      )
    ```

=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Mocks"

    var simple_math: SimpleMath

    func before_case(__):
      simple_math = mock(SimpleMath)

      # Specify default answers
      when(simple_math.times).then_return(0)
      when(simple_math.sum).then_return(0)

    func test_return_configured_answer():
      when(simple_math.times).with_args([2.0, 2.0]).then_return(5)
      expect_equal(simple_math.times(2, 2), 5)

    func test_method_was_called_at_least_once():
      simple_math.times(4, 4)

      var calls := get_calls_of(simple_math.times)
      expect(not calls.is_empty(), "Method was not called!")

    func test_method_was_called_with_parameters():
      simple_math.times(2, 4)
      expect_contains(get_calls_of(simple_math.times), [2.0, 4.0])
    ```

=== "simple-math.gd"
    ```gdscript
    extends RefCounted
    class_name SimpleMath

    func times(a: float, b: float) -> float:
      return a * b

    func sum(a, b):
      return a + b
    ```

## Creating mocks

Call `mock()` with the desired class, and it will return a mocked instance.

Under the hood, *vest* creates a new class that extends the class being mocked.
This mock class will record all function calls, and delegate them to the
defined answers.

### Limitations

Inner classes are not supported at the moment.

Built-in classes are not supported at the moment.

Default values in methods might not work, requiring calls where each parameter
is present.

Since property setters and getters can't be overridden in extending classes,
they are not supported.

!!!tip
    Many Godot classes implement `get_property()` and `set_property()` methods
    and then use those as getters and setters for `property`. Using this
    pattern, *vest* can mock the getter and setter methods, which would be then
    used by the property.

## Defining answers

Unless an answer is defined for the call, mocked methods won't return anything.
Answers may be defined for any call to the method, or for calls with specific
parameter values. Answers with parameter values take precedence over generic
answers.

Use `when()` to start defining an answer for a given method call, passing in
the method itself as parameter. Optionally call `with_args()` on the result, to
specify expected parameter values.

!!!warning
    Make sure that the expected parameter values are the right type! In the
    example, we intentionally pass in `[2.0, 2.0]` as expected parameters -
    even though `[2, 2]` is more natural to write, they are ints, and the
    method is called with floats, so the answer won't match any calls.

`.then_return()`
:   Returns the value passed in as parameter.

`.then_answer()`
:   Takes a callable as parameter. Whenever the answer is used, it will call
    the specified callable and return its return value. The callable receives
    an array, containing the parameters used to call the mocked method.

## Asserting calls

Use `get_calls_of()` to retrieve all the calls of a mocked method. Similarly to
[captured signals], the result is an array of arrays, where each individual
array contains the arguments used to call the mocked method.

Since these are just arrays, the [assert library] can be used to verify
requirements.


[test doubles]: http://xunitpatterns.com/Test%20Double.html
[captured signals]: ./capturing-signals.md
[assert library]: ./assertions.md
