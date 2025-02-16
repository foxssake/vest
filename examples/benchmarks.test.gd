extends VestTest

func get_suite_name() -> String:
	return "Benchmarks"

func test_string_concatenation():
	var line := "a".repeat(128) + "\n"
	var buffer_string := ""
	var buffer_array := PackedStringArray()

	measure("String", func():
		buffer_string += line
	).with_iterations(16384).run()

	measure("PackedStringArray", func():
		buffer_array.append(line)
	).with_iterations(16384).run()
