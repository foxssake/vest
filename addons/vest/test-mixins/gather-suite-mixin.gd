extends "res://addons/vest/vest-test-base.gd"

func _get_ignored_methods() -> Array[String]:
	return ["get_suite_name"]

func _get_suite_name() -> String:
	# Check if callback is implemented
	if has_method("get_suite_name"):
		return call("get_suite_name")

	# Check if class_name is set
	var script := get_script() as Script
	var pattern := RegEx.create_from_string("class_name\\s+([^\n\\s]+)")
	var hit := pattern.search(script.source_code)

	if hit:
		return hit.get_string(1)

	# Fall back to script path
	return script.resource_path

func _get_suite() -> VestSuite:
	var suite := VestSuite.new()

	var script := get_script() as Script
	var ignored_methods := _get_ignored_methods()
	var inherited_methods := (script.get_base_script()
		.get_script_method_list()
		.map(func(it): return it["name"])
	)

	var methods := (script.get_script_method_list()
		.filter(func(it): return not it["name"].begins_with("_"))
		.filter(func(it): return not inherited_methods.has(it["name"]))
		.filter(func(it): return not ignored_methods.has(it["name"]))
		)

	var define_methods := (methods
		.filter(func(it): return not it["return"]["class_name"].is_empty())
		.map(func(it): return it["name"])
	)

	var case_methods := (methods
		.filter(func(it): return not define_methods.has(it["name"]))
		.map(func(it): return it["name"])
	)

	return define(_get_suite_name(), func():
		for method in define_methods:
			call(method)

		for method in case_methods:
			test(method.capitalize(), func(): call(method))
	)
