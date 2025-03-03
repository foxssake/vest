# Coroutines

*vest* also supports coroutines. This enables writing asynchronous tests where
you need to wait for signals or other coroutines.

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Coroutines"

    func suite():
      # Coroutines are also supported when defining tests
      await Vest.sleep(0.01)

      test("Think of a number", func():
        var number := await think_of_a_number()

        expect_contains(range(0, 10), number)
      )

    func think_of_a_number() -> int:
      # Think for a bit
      await Vest.sleep(0.05)
      return randi() % 10
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Coroutines"

    func test_think_of_a_number():
      var number := await think_of_a_number()

      expect_contains(range(0, 10), number)

    func think_of_a_number() -> int:
      # Think for a bit
      await Vest.sleep(0.05)
      return randi() % 10
    ```

Coroutines are supported in tests ( both with `test()` and test methods ), and
in suite definitions ( both in `define()` and suite methods ).
