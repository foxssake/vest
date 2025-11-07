extends VestTest

func get_suite_name():
	return "Fuzzy Search"

func test_single():
	var cases := get_cases()

	var word := "should"
	var idx := 0

	benchmark("Single score", func(__):
		VestUI.fuzzy_score(word, cases[idx % cases.size()])
		idx += 1
	)\
		.with_duration(1.)\
		.with_batch_size(1024)\
		.run()

func test_cached_scoring():
	var cases := get_cases()
	var word := "should"

	benchmark("Score %d lines with cache" % [cases.size()], func(__):
		var scores := {}
		var result := cases.duplicate()
		for haystack in cases:
			var score := VestUI.fuzzy_score(word, haystack)
			if score > 0.:
				scores[haystack] = score
		result.sort_custom(func(a, b): return scores[a] < scores[b])
	)\
		.with_duration(5.)\
		.run()

func test_naive_scoring():
	var cases := get_cases()
	var word := "should"

	benchmark("Naively score %d lines" % [cases.size()], func(__):
		var result := cases.duplicate()
		result.sort_custom(VestUI.fuzzy_sorter(word))
	)\
		.with_duration(5.)\
		.run()

func get_cases() -> Array[String]:
	return [
		"Autoload",
		"Autoload",
		"Emit Performance",
		"Benchmarks",
		"await from suite",
		"await in define()",
		"await from suite",
		"Await From Method",
		"Coroutine",
		"should match",
		"should not match",
		"should substitute",
		"FilenamePattern",
		"should match in order ",
		"should match in order ",
		"should match in order ",
		"should match out of order ",
		"should match out of order ",
		"Performance",
		"Fuzzy Search",
		"Should Return Default",
		"Should Return On Args",
		"Should Return Default On Wrong Args",
		"Should Answer Default",
		"Should Answer On Args",
		"Should Answer Default On Wrong Args",
		"Should Record Calls",
		"Mocks",
		"Addition#1 [2, 5, 7]",
		"Addition#2 [\"foo\", \"bar\", \"foobar\"]",
		"Addition#3 [[1, 2], [3, 0], [1, 2, 3, 0]]",
		"Parameterized",
		"should process frames",
		"SceneTree",
		"should serialize to args",
		"should parse",
		"CLI Params",
		"VestCLI",
		"Bool",
		"Int",
		"Float",
		"String",
		"Array",
		"Vector",
		"Color",
		"Basis",
		"Packed Byte Array",
		"Serializable Object",
		"Object",
		"Dictionary",
		"Nested",
		"Circular Reference",
		"Null",
		"VestDataSerializer",
		"string",
		"string name",
		"array",
		"dictionary",
		"custom",
		"custom without overloads",
		"equals",
		"string",
		"string name",
		"array",
		"dictionary",
		"custom",
		"custom without overloads",
		"is_empty",
		"string",
		"string name",
		"array",
		"dictionary",
		"custom",
		"custom without overloads",
		"contains",
		"Matchers"
	]
