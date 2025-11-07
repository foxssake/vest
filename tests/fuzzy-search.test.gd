extends VestTest

func get_suite_name():
	return "Fuzzy Search"

func suite():
	var ordered_matches := [
		["he", "shells"],
		["eh", "seashells"],
		["war", "awards"]
	]

	var unordered_matches := [
		["foobar", "barfoo"],
		["test vest", "VestTest"]
	]

	for ordered in ordered_matches:
		test("should match in order - %s in %s" % ordered, func():
			expect(VestUI.fuzzy_match(ordered[0], ordered[1]), "No match!")
			expect(VestUI.fuzzy_score(ordered[0], ordered[1]) >= 1., "Match was not ordered!")
			Vest.message("Score: %.2f" % [VestUI.fuzzy_score(ordered[0], ordered[1])])
		)

	for unordered in unordered_matches:
		test("should match out of order - %s in %s" % unordered, func():
			expect(VestUI.fuzzy_match(unordered[0], unordered[1]), "No match!")
			expect(VestUI.fuzzy_score(unordered[0], unordered[1]) < 1., "Match was not unordered!")
			Vest.message("Score: %.2f" % [VestUI.fuzzy_score(unordered[0], unordered[1])])
		)
