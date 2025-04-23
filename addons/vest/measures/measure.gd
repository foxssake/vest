var _metric: StringName = &""

func _init(p_metric: StringName):
	_metric = p_metric

func get_metric_name() -> StringName:
	return _metric

func get_measure_name() -> String:
	return ""

func get_value() -> Variant:
	return null

func ingest(_value: Variant) -> void:
	pass
