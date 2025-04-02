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
      await Vest.sleep()

      # Async define()'s are supported too
      # NOTE: Make sure to `await` async defines!
      await define("Async suite", func():
        # Think a bit before specifying the test
        await Vest.sleep()
        
        test("Think of a number", func():
          var number := await think_of_a_number()

          expect_contains(range(0, 10), number)
        )
      )

	# Async signal handlers are also supported
	on_begin.connect(func(): await Vest.sleep())
	on_finish.connect(func(): await Vest.sleep())

    func think_of_a_number() -> int:
      # Think for a bit
      await Vest.sleep()
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

    func before_all():
      await Vest.sleep()

    func after_all():
      await Vest.sleep()

    func think_of_a_number() -> int:
      # Think for a bit
      await Vest.sleep()
      return randi() % 10
    ```

Coroutines are supported in tests ( both with `test()` and test methods ), and
in suite definitions ( both in `define()` and suite methods ).

As shown, asynchronous lifecycle hooks are also supported.

!!!warning
    Make sure to `await` when using `define()` with coroutines! Otherwise,
    Godot may run into a stack overflow.
