extends VestTest
class_name DefineTest

func suite():
	test("Pass", func(): ok())
	test("Fail", func(): fail())
	test("Skip", func(): skip())
	test("Todo", func(): todo())
	test("Void", func(): return)

	test("Failing comparison", func():
		expect_equal([1, 2, 3], [1, 5, 3])
	)

	test("Multiline message", func():
		fail("Failing for\n\treasons")
	)
