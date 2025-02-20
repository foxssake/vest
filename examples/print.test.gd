extends VestTest

func get_suite_name() -> String:
	return "Print test"

func suite():
	test("Custom message", func():
		var date := Time.get_date_dict_from_system()
		var date_string := "%d-%02d-%02d" % [date["year"], date["month"], date["day"]]
		Vest.message("Tests ran on %s" % [date_string])
		ok()
	)

func test_custom_message():
	var date := Time.get_date_dict_from_system()
	var date_string := "%d-%02d-%02d" % [date["year"], date["month"], date["day"]]
	Vest.message("Tests ran on %s" % [date_string])
	ok()
