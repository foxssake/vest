extends Vest.Measure

var _value: Variant = null

func _init(p_metric: StringName):
  super(p_metric)

func get_measure_name() -> String:
  return "value"

func get_value() -> Variant:
  return _value

func ingest(value: Variant) -> void:
  _value = value

