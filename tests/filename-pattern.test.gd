extends VestTest

func get_suite_name():
	return "FilenamePattern"

func suite():
	test("should match", func():
		var pattern := FilenamePattern.new("*.test.gd")

		expect(pattern.matches("foo.test.gd"), "Pattern should match!")
		expect_equal(pattern.reverse("foo.test.gd"), "foo.gd")
	)

	test("should not match", func():
		var pattern := FilenamePattern.new("*.test.gd")

		expect_not(pattern.matches("test_foo.gd"), "Pattern should not match!")
		expect_equal(pattern.reverse("test_foo.gd"), "")
	)

	test("should substitute", func():
		var pattern := FilenamePattern.new("*.test.gd")

		expect_equal(pattern.substitute("assert.gd"), "assert.test.gd")
	)
