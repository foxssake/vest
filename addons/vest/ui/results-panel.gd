@tool
extends Panel

var visibility_popup: VestUI.VisibilityPopup

@onready var _tree := %Tree as Tree
@onready var _spinner := %Spinner as Control
@onready var _spinner_icon := %"Spinner Icon" as TextureRect
@onready var _spinner_label := %"Spinner Label" as Label
@onready var _animation_player := $PanelContainer/Spinner/AnimationPlayer as AnimationPlayer

var _results: VestResult.Suite = null
var _render_results: VestResult.Suite = null
var _search_string: String = ""

signal on_collapse_changed()

func get_results() -> VestResult.Suite:
	return _results

func set_results(results: VestResult.Suite) -> void:
	if _results != results:
		_results = results
		_render()

func get_search_string() -> String:
	return _search_string

func set_search_string(search_string: String) -> void:
	if _search_string != search_string:
		_search_string = search_string
		_render()

func clear() -> void:
	set_results(null)

func set_spinner(text: String, icon: Texture2D = null, animated: bool = true) -> void:
	clear()
	_spinner_icon.texture = icon
	_spinner_label.text = text
	_spinner.show()
	if animated:
		_animation_player.play("spin")
	else:
		_animation_player.stop()

func collapse() -> void:
	var root := _tree.get_root()
	if not root: return

	for item in root.get_children():
		item.set_collapsed_recursive(true)

func expand() -> void:
	var root := _tree.get_root()
	if not root: return

	for item in root.get_children():
		item.set_collapsed_recursive(false)

func toggle_collapsed() -> void:
	if is_any_collapsed():
		expand()
	else:
		collapse()

func is_any_collapsed() -> bool:
	var at := _tree.get_root()
	var queue := [] as Array[TreeItem]

	while at:
		queue.append_array(at.get_children())

		if at.collapsed:
			return true
		at = queue.pop_back()

	return false

func _ready():
	_tree.item_collapsed.connect(func(_item):
		on_collapse_changed.emit()
	)

func _clear():
	_tree.clear()
	for connection in _tree.item_activated.get_connections():
		connection["signal"].disconnect(connection["callable"])
	_spinner.hide()

func _render():
	_clear()
	if _results != null:
		_render_results = VestResult.Suite._from_wire(_results._to_wire()) # HACK: Duplicate
		_filter_visibility(_render_results)
		_filter_search(_render_results, _search_string)
		_render_result(_render_results, _tree)

func _filter_visibility(results: VestResult.Suite) -> void:
	for case in results.cases:
		if not _check_visibility(case):
			results.cases.erase(case) # TODO: Does this break?

	for subsuite in results.subsuites:
		if not _check_visibility(subsuite):
			results.subsuites.erase(subsuite)
		else:
			_filter_visibility(subsuite)

func _filter_search(results: VestResult.Suite, needle: String) -> void:
	if not needle:
		# Search string empty, do nothing
		return

	var scores := {}
	var parents := {}
	var at := results
	var queue: Array[VestResult.Suite] = []
	var leaves: Array[VestResult.Suite] = []

	# Calculate scores
	while at:
		for subsuite in at.subsuites:
			queue.append(subsuite)
			parents[subsuite] = at

		if at.subsuites.is_empty():
			leaves.append(at)

		scores[at] = VestUI.fuzzy_score(needle, at.suite.name)
		print("Score(%s): %.2f" % [at.suite.name, scores[at]])
		for case in at.cases:
			scores[case] = VestUI.fuzzy_score(needle, case.case.description)
			print("Score(%s): %.2f" % [case.case.description, scores[case]])

		at = queue.pop_back() as VestResult.Suite

	# Propagate best scores from leaves
	print("Leaves: %s" % [leaves.map(func(it): return it.suite.name)])
	for leaf in leaves:
		at = leaf
		
		# Calculate best score for leaf
		var best_score := scores[at] as float
		for case in at.cases:
			best_score = maxf(best_score, scores[case])
		print("Best(%s): %.2f ( %s )" % [at.suite.name, best_score, at.cases.map(func(it): return scores[it])])
		
		# Propagate upwards in tree
		while at:
			scores[at] = maxf(scores[at], best_score)
			best_score = maxf(best_score, scores[at])
			print("Propagate(%s): %.2f, proceed %.2f" % [at.suite.name, scores[at], best_score])
			at = parents.get(at, null)
	
	# Remove results that don't match the search string
	at = results
	queue.clear()
	while at:
		for case in at.cases:
			if scores[case] <= 0.0:
				at.cases.erase(case) # TODO: Does this break?
		for subsuite in at.subsuites:
			if scores[subsuite] <= 0.0:
				at.subsuites.erase(subsuite) # TODO: Does this break?

		queue.append_array(at.subsuites)
		at = queue.pop_back()

func _check_visibility(what: Variant) -> bool:
	if what is VestResult.Case:
		var case := what as VestResult.Case
		return visibility_popup.get_visibility_for(case.status)
	elif what is VestResult.Suite:
		var suite := what as VestResult.Suite
		for status in suite.get_unique_statuses():
			if visibility_popup.get_visibility_for(status):
				return true
		return false
	else:
		push_warning("Checking visibility for unknown item: %s" % [what])
		return true

func _render_result(what: Object, tree: Tree, parent_result: Variant = null, parent: TreeItem = null):
	if what is VestResult.Suite:
		var item := tree.create_item(parent)
		item.set_text(0, what.suite.name)
		item.set_text(1, what.get_aggregate_status_string().capitalize())

		item.set_icon(0, VestUI.get_status_icon(what))
		item.set_icon_max_width(0, VestUI.get_icon_size())

		tree.item_activated.connect(func():
			if tree.get_selected() == item:
				_navigate(what.suite.definition_file, what.suite.definition_line)
		)

		for subsuite in what.subsuites:
			_render_result(subsuite, tree, what, item)
		for case in what.cases:
			_render_result(case, tree, what, item)
	elif what is VestResult.Case:
		var item := tree.create_item(parent)
		item.set_text(0, what.case.description)
		item.set_text(1, what.get_status_string().capitalize())
		item.collapsed = what.status == VestResult.TEST_PASS

		item.set_icon(0, VestUI.get_status_icon(what))
		item.set_icon_max_width(0, VestUI.get_icon_size())

		_render_data(what, tree, item)

		tree.item_activated.connect(func():
			if tree.get_selected() == item:
				_navigate(what.case.definition_file, what.case.definition_line)
		)
	else:
		push_error("Rendering unknown object: %s" % [what])

func _render_data(case: VestResult.Case, tree: Tree, parent: TreeItem):
	var data := case.data.duplicate()

	if case.message:
		var item := tree.create_item(parent)
		item.set_text(0, case.message)

		tree.item_activated.connect(func():
			if tree.get_selected() == item:
				# TODO: popup_dialog()
				add_child(VestMessagePopup.of(case.message).window)
		)

	if data == null or data.is_empty():
		return

	if data.has("messages"):
		var header_item := tree.create_item(parent)
		header_item.set_text(0, "Messages")

		for message in data["messages"]:
			tree.create_item(header_item).set_text(0, message)

		data.erase("messages")

	if data.has("benchmarks"):
		var header_item := tree.create_item(parent)
		header_item.set_text(0, "Benchmarks")

		for benchmark in data["benchmarks"]:
			var benchmark_item = tree.create_item(header_item)
			benchmark_item.set_text(0, benchmark["name"])
			if benchmark.has("duration"): benchmark_item.set_text(1, benchmark["duration"])

			for measurement in benchmark.keys():
				if measurement == "name": continue

				var measurement_item := tree.create_item(benchmark_item)
				measurement_item.set_text(0, str(measurement).capitalize())
				measurement_item.set_text(1, str(benchmark[measurement]))

		data.erase("benchmarks")

	if data.has("expect") and data.has("got"):
		var header_item := tree.create_item(parent)
		header_item.set_text(0, "Got:")
		header_item.set_text(1, "Expected:")

		var got_string := JSON.stringify(data["got"], "  ")
		var expect_string := JSON.stringify(data["expect"], "  ")

		var comparison_item := tree.create_item(header_item)
		comparison_item.set_text(0, got_string)
		comparison_item.set_text(1, expect_string)

		tree.item_activated.connect(func():
			# TODO: popup_dialog()
			if tree.get_selected() in [header_item, comparison_item]:
				add_child(VestComparisonPopup.of(expect_string, got_string).window)
		)

		data.erase("got")
		data.erase("expect")

	for key in data:
		var item := tree.create_item(parent)
		item.set_text(0, var_to_str(key))
		item.set_text(1, var_to_str(data[key]))

func _navigate(file: String, line: int):
	Vest._get_editor_interface().edit_script(load(file), line)

func _match_search(needle: String, haystack: Variant, parent: Variant = null) -> bool:
	if haystack is VestResult.Suite:
		var suite := haystack as VestResult.Suite
		if VestUI.fuzzy_score(needle, suite.suite.name) > 1.0:
			return true

		for case in suite.cases:
			if _match_search(needle, case, suite):
				return true
		for subsuite in suite.subsuites:
			if _match_search(needle, subsuite, suite):
				return true

		return false
	elif haystack is VestResult.Case:
		var case := haystack as VestResult.Case

		if VestUI.fuzzy_score(needle, case.case.description) > 1.0:
			return true
		if parent != null and parent is VestResult.Suite:
			return VestUI.fuzzy_score(needle, parent.suite.name) > 1.0
		else:
			return false
	else:
		push_warning("Matching unknown item: %s" % [haystack])
		return true
