extends RefCounted
class_name SimpleMath

var some_property:
	get:
		print("Getting property!")
		return 8
	set(v):
		print("Setting property! %s" % [v])

func times(a: float, b: float) -> float:
	return a * b

func sum(a, b):
	return a + b

func accept(value) -> void:
	pass
