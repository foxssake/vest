extends VestTest

func get_suite_name():
	return "VestUI.format_duration()"

func suite():
	var cases := [
		["minutes", 150., "2.50min"],
		["seconds", 17.85, "17.85s"],
		["milliseconds", 0.758, "758.00ms"],
		["microseconds", 0.000_004_520, "4.52µs"],
		["rounding", 1.1705, "1.17s"]
	]

	for case in cases:
		test(case[0], func(): expect_equal(VestUI.format_duration(case[1]), case[2]))
