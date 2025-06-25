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
