extends VestTest

func get_suite_name() -> String:
	return "Lifecycle hooks test"

func suite():
	on_suite_begin.connect(func(p_suite: VestDefs.Suite):
		print("Starting suite " + p_suite.name)
	)

	on_case_begin.connect(func(case: VestDefs.Case):
		print("Starting case " + case.description)
	)

	on_case_finish.connect(func(case: VestDefs.Case):
		print("Finishing case " + case.description)
	)

	on_suite_finish.connect(func(p_suite: VestDefs.Suite):
		print("Finishing suite " + p_suite.name)
	)

	test("First test", func(): ok())
	test("Second test", func(): ok())

func before_suite(p_suite: VestDefs.Suite):
	print("Starting suite " + p_suite.name)

func before_case(case: VestDefs.Case):
	print("Starting case " + case.description)

func after_case(case: VestDefs.Case):
	print("Finishing case " + case.description)

func after_suite(p_suite: VestDefs.Suite):
	print("Finishing suite " + p_suite.name)

func test_first():
	ok()

func test_second():
	ok()
