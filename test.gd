extends VestTest

func get_suite() -> VestSuite:
	return define("Vest", func():
		test("Some test", func(): return false)
		test("Another test", func(): return true)
	)
