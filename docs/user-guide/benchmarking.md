# Benchmarking

*Vest* can also serve as a benchmark runner. Benchmarks can help you find the
most performant implementation of a particular feature, or making sure its
performance meets your criteria.

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Benchmarks"

    func suite():
      test("Random ID generation", func():
        var length := 16
        var charset := "abcdefghijklmnopqrstuvwxyz0123456789"

        var concat := benchmark("String concatenation", func():
          var _id := ""
          for i in range(length):
            _id += charset[randi() % charset.length()]
        ).with_iterations(1_000).run()

        var rangemap := benchmark("Range mapping", func():
          var _id := "".join(
            range(length)
              .map(func(__): return charset[randi() % charset.length()])
            )
        ).with_iterations(1_000).run()

        var psa := benchmark("PackedStringArray", func():
          var chars := PackedStringArray()
          for i in range(length):
            chars.append(charset[randi() % charset.length()])
          var _id := "".join(chars)
        ).with_iterations(1_000).run()

        expect(concat.get_iters_per_sec() > 100_000, "Concatenation was too slow!")
        expect(rangemap.get_iters_per_sec() > 100_000, "Rangemapping was too slow!")
        expect(psa.get_iters_per_sec() > 100_000, "PackedStringArray was too slow!")
      )
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Benchmarks"

    func test_random_id_generation():
      var length := 16
      var charset := "abcdefghijklmnopqrstuvwxyz0123456789"

      var concat := benchmark("String concatenation", func():
        var _id := ""
        for i in range(length):
          _id += charset[randi() % charset.length()]
      ).with_iterations(1_000).run()

      var rangemap := benchmark("Range mapping", func():
        var _id := "".join(
          range(length)
            .map(func(__): return charset[randi() % charset.length()])
          )
      ).with_iterations(1_000).run()

      var psa := benchmark("PackedStringArray", func():
        var chars := PackedStringArray()
        for i in range(length):
          chars.append(charset[randi() % charset.length()])
        var _id := "".join(chars)
      ).with_iterations(1_000).run()

      expect(concat.get_iters_per_sec() > 100_000, "Concatenation was too slow!")
      expect(rangemap.get_iters_per_sec() > 100_000, "Rangemapping was too slow!")
      expect(psa.get_iters_per_sec() > 100_000, "PackedStringArray was too slow!")
    ```

## Specifying the benchmark

To begin specifying a benchmark, call `benchmark()` with a name and callable to
run. You can apply limits on how long or how many times to run the callable
with `.with_duration()` or `.with_iterations()`. If no limits are specified,
the benchmark is only ran once.

With the limits in place, call `.run()` to perform the benchmark.

## Inspecting results

The specified benchmark is returned as an object, that can be inspected. This
can be useful in many situations, including custom reporting and asserting for
key performance metrics.
