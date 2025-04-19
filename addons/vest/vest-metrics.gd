extends Object
class_name VestMetrics
# TODO: Consider separating into multiple scripts?

class Measure:
	var _metric: StringName = &""

	func _init(p_metric: StringName):
		_metric = p_metric

	func get_metric_name() -> StringName:
		return _metric

	func get_measure_name() -> String:
		return ""

	func get_value() -> Variant:
		return null

	func ingest(value: Variant) -> void:
		pass

class LastValueMeasure extends Measure:
	var _value: Variant = null

	func _init(p_metric: StringName):
		super(p_metric)

	func get_measure_name() -> String:
		return "value"

	func get_value() -> Variant:
		return _value

	func ingest(value: Variant) -> void:
		_value = value

class AverageMeasure extends Measure:
	var _sum: Variant
	var _count: int = 0

	func _init(p_metric: StringName):
		super(p_metric)

	func get_measure_name() -> String:
		return "average"

	func get_value() -> Variant:
		return _sum / _count

	func ingest(value: Variant) -> void:
		_sum = _sum + value if _count else value
		_count += 1

class SumMeasure extends Measure:
	var _sum: Variant
	var _has: bool = false

	func _init(p_metric: StringName):
		super(p_metric)

	func get_measure_name() -> String:
		return "sum"

	func get_value() -> Variant:
		return _sum

	func ingest(value: Variant) -> void:
		_sum = _sum + value if _has else value
		_has = true

class MinMeasure extends Measure:
	var _min: Variant
	var _has: bool = false

	func _init(p_metric: StringName):
		super(p_metric)

	func get_measure_name() -> String:
		return "min"

	func get_value() -> Variant:
		return _min

	func ingest(value: Variant) -> void:
		_min = min(_min, value) if _has else value
		_has = true

class MaxMeasure extends Measure:
	var _max: Variant
	var _has: bool = false

	func _init(p_metric: StringName):
		super(p_metric)

	func get_measure_name() -> String:
		return "max"

	func get_value() -> Variant:
		return _max

	func ingest(value: Variant) -> void:
		_max = max(_max, value) if _has else value
		_has = true
