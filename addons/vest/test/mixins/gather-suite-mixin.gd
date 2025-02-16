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
	var parametric_methods: Array[Dictionary] = []

	for method in methods:
		if method["name"].begins_with("suite"):
			define_methods.append(method)
		elif method["name"].begins_with("test") and not method["default_args"].is_empty() and method["default_args"][0] is String:
			parametric_methods.append(method)
		elif method["name"].begins_with("test"):
			case_methods.append(method)

	return define(_get_suite_name(), func():
		for method in define_methods:
			call(method["name"])

		for method in case_methods:
			test(method["name"].trim_prefix("test").capitalize(), func(): call(method["name"]))

		for method in parametric_methods:
			var param_provider_name := method["default_args"][0] as String
			if not has_method(param_provider_name):
				push_warning(
					"Can't run parametrized test \"%s\", provider method \"%s\" is missing!" % \
					[method["name"], param_provider_name]
				)

			var params = call(param_provider_name)
			if not params is Array or not params.all(func(it): return it is Array):
				push_warning(
					"Can't run parametrized test \"%s\", provider \"%s\" didn't return array or arrays: %s" % \
					[method["name"], param_provider_name, params]
				)

			for i in range(params.size()):
				test(
					"%s#%d %s" % [method["name"].trim_prefix("test").capitalize(), i+1, params[i]],
					func(): callv(method["name"], params[i])
				)
	)
