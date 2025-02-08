extends VestTestMixin

func _get_ignored_methods() -> Array[String]:
	return [
		"get_suite_name",
		"before_suite", "before_case", "before_benchmark", "before_each",
		"after_suite", "after_case", "after_benchmark", "after_each"
	]

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

func _get_suite() -> VestDefs.Suite:
	var suite := VestDefs.Suite.new()

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

	var define_methods: Array[Dictionary] = []
	var case_methods: Array[Dictionary] = []
	var benchmark_methods: Array[Dictionary] = []

	for method in methods:
		if not method["return"]["class_name"].is_empty():
			define_methods.append(method)
		elif method["name"].begins_with("benchmark"):
			if (method["args"].any(func(arg): return arg["name"] == "iterations") or \
				method["args"].any(func(arg): return arg["name"] == "timeout")) and \
				method["default_args"].size() > 0:
				benchmark_methods.append(method)
		else:
			case_methods.append(method)

	return define(_get_suite_name(), func():
		for method in define_methods:
			call(method["name"])

		for method in case_methods:
			test(method["name"].capitalize(), func(): call(method["name"]))

		for method in benchmark_methods:
			var max_iterations = -1
			var timeout = -1.

			for arg_idx in range(method["args"].size()):
				var arg = method["args"][arg_idx]["name"]
				var value = method["default_args"][arg_idx]

				match arg:
					"iterations": max_iterations = value
					"timeout": timeout = value

			benchmark(method["name"].capitalize(), func(): call(method["name"]))\
				.with_iterations(max_iterations)\
				.with_timeout(timeout)
	)
