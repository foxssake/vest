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

        var concat := benchmark("String concatenation", func(__):
          var _id := ""
          for i in range(length):
            _id += charset[randi() % charset.length()]
        ).with_iterations(1_000).run()

        var rangemap := benchmark("Range mapping", func(__):
          var _id := "".join(
            range(length)
              .map(func(__): return charset[randi() % charset.length()])
            )
        ).with_iterations(1_000).run()

        var psa := benchmark("PackedStringArray", func(__):
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

      var concat := benchmark("String concatenation", func(__):
        var _id := ""
        for i in range(length):
          _id += charset[randi() % charset.length()]
      ).with_iterations(1_000).run()

      var rangemap := benchmark("Range mapping", func(__):
        var _id := "".join(
          range(length)
            .map(func(__): return charset[randi() % charset.length()])
          )
      ).with_iterations(1_000).run()

      var psa := benchmark("PackedStringArray", func(__):
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

## Custom metrics

Aside from pure performance, *vest* can measure arbitrary custom values in
tests. This is done by emitting named *metrics*. These *metrics* are then
processed into the specified *measurements* by *vest*.

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Benchmarks"

    func suite():
      test("Array serialization", func():
        var buffer := StreamPeerBuffer.new()

        var array := benchmark("Array", func(emit: Callable):
          buffer.clear()
          buffer.put_var([1, 2, 3, 4])
          emit.call(&"Size", buffer.get_size())
        )\
          .without_builtin_measures()\
          .measure_value(&"Size")\
          .once()

        var packed_array := benchmark("PackedInt32Array", func(emit):
          buffer.clear()
          buffer.put_var(PackedInt32Array([1, 2, 3, 4]))
          emit.call(&"Size", buffer.get_size())
        )\
          .without_builtin_measures()\
          .measure_value(&"Size")\
          .once()

        expect(array.get_measurement(&"Size", &"value") < 80, "Array too large!")
        expect(packed_array.get_measurement(&"Size", &"value") < 80, "PackedArray too large!")
      )
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Benchmarks"

    func test_array_serialization():
      var buffer := StreamPeerBuffer.new()

      var array := benchmark("Array", func(emit: Callable):
        buffer.clear()
        buffer.put_var([1, 2, 3, 4])
        emit.call(&"Size", buffer.get_size())
      )\
        .without_builtin_measures()\
        .measure_value(&"Size")\
        .once()

      var packed_array := benchmark("PackedInt32Array", func(emit):
        buffer.clear()
        buffer.put_var(PackedInt32Array([1, 2, 3, 4]))
        emit.call(&"Size", buffer.get_size())
      )\
        .without_builtin_measures()\
        .measure_value(&"Size")\
        .once()

      expect(array.get_measurement(&"Size", &"value") < 80, "Array too large!")
      expect(packed_array.get_measurement(&"Size", &"value") < 80, "PackedArray too large!")
    ```

!!!tip
    If the built-in measurements are not needed for your test, call
    `.without_builtin_measures()` on your benchmark.

### Emitting metrics

Every benchmark function receives a special parameter - the `emit()` Callable.
Inside the benchmark, this can be called to emit custom metrics during testing.

Metrics are `StringName`s, since they are usually hard-coded and take on a
limited set of values.

To emit a custom metric value, call the method with the metric name and the
value to emit:

```gdscript
emit.call(&"Metric name", 15.0)
```

### Specifying measurements

In order to turn these custom metric values into reportable data, they are
processed using *measurements*. Each measurement processes the incoming metric
values differently.

Each measurement has a name, which are specified next to the method.

`.measure_value()` ⇒ `value`
: Retain the last emitted value of the specified metric. Useful for metrics
  that are emitted only once.

`.measure_average()` ⇒ `average`
: Calculate the average of the emitted values.

`.measure_max()` ⇒ `max`
: Retain the largest of the emitted values.

`.measure_min()` ⇒ `min`
: Retain the smallest of the emitted values.

`.measure_sum()` ⇒ `sum`
: Retain the sum of the emitted values.

### Implementing custom measurements

If the built-in measurements are not enough, you can implement your own, custom
measurements as well.

To do so, create a class that extends the `VestMeasure` class and implement its
methods flagged with *override* in its docs. Take a median measure for example:

```gdscript
extends VestMeasure
class_name MedianMeasure

## Measures the median of a metric.

var _values: Array = []
var _count: int = 0
var _is_sorted: bool = false

func get_measure_name() -> String:
	return "median"

func get_value() -> Variant:
	if _values.is_empty():
		return null

	if not _is_sorted:
		_values.sort()
		_is_sorted = true

	return _values[_values.size() / 2]

func ingest(value: Variant) -> void:
	_is_sorted = false
	_values.push_back(value)
```

Once that's done, call `.with_measure()` on your benchmark, passing in an
instance of your custom measurement class:

```gdscript
var rng := benchmark("Random values", func(emit: Callable):
  emit(&"Random", randf())
)\
  .with_measure(MedianMeasure.new(&"Random"))\
  .with_iterations(1000)\
  .run()
```

This new measurement will show up in the test report.

### Inspecting measurements

Each measurement has a name, as specified in the previous chapters. Query the
measured value ( as it appears in the report ) by combining the metric and
measurement names:

```gdscript
rng.get_measurement(&"Random", &"median")
```

This returns a value that can be inspected and asserted against like any other
numeric value.

