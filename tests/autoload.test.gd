extends VestTest

func get_suite_name() -> String:
	return "Autoload"

func test_autoload():
	expect_equal(Autoload.greet(), "Hello from Autoload!")
