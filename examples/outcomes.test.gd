extends VestTest

func get_suite_name() -> String:
	return "Test outcomes"

func suite():
	test("Pass", func(): ok("This test passes"))
	test("Fail", func(): fail("This test fails"))
	test("Skip", func(): skip("This test should be skipped"))
	test("TODO", func(): todo("This test is not implemented yet"))
	test("Void", func(): pass) # This test has no outcome

	test("Multiple messages", func():
		fail("This test will fail")
		fail("But this message will also be recorded!")
		expect_equal(2, 3) # And this too!
		expect_equal(5, 7) # And this assert will be recorded as well!
	)

func test_pass():
	ok("This test passes")

func test_fail():
	fail("This test fails")

func test_skip():
	skip("This test should be skipped")

func test_todo():
	todo("This test is not implemented yet")

func test_void():
	# This test has no outcome
	pass

func test_multiple_messages():
	fail("This test will fail")
	fail("But this message will also be recorded!")
	expect_equal(2, 3) # And this too!
	expect_equal(5, 7) # And this assert will be recorded as well!
