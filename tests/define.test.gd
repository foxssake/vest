extends VestTest
class_name DefineTest

func suite():
	define("Status suite", func():
		test("Pass", func(): ok())
		test("Fail", func(): fail())
		test("Skip", func(): skip())
		test("Todo", func(): todo())
		test("Void", func(): return)
	)
