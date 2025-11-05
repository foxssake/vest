@tool
extends Panel

var visibility_popup: VestUI.VisibilityPopup

@onready var _tree := %Tree as Tree
@onready var _spinner := %Spinner as Control
@onready var _spinner_icon := %"Spinner Icon" as TextureRect
@onready var _spinner_label := %"Spinner Label" as Label
@onready var _animation_player := $PanelContainer/Spinner/AnimationPlayer as AnimationPlayer

var _results: VestResult.Suite = null

func get_results() -> VestResult.Suite:
	return _results

func set_results(results: VestResult.Suite) -> void:
	if _results != results:
		_results = results
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

func _clear():
	_tree.clear()
	for connection in _tree.item_activated.get_connections():
		connection["signal"].disconnect(connection["callable"])
	_spinner.hide()

func _render():
	_clear()
	if _results != null:
		_render_result(_results, _tree)

func _render_result(what: Object, tree: Tree, parent: TreeItem = null):
	if what is VestResult.Suite:
		# Skip if no statuses match the visibility filter
		if not what.get_unique_statuses()\
			.any(func(status): return visibility_popup.get_visibility_for(status)):
			return
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
			_render_result(subsuite, tree, item)
		for case in what.cases:
			_render_result(case, tree, item)
	elif what is VestResult.Case:
		if not visibility_popup.get_visibility_for(what.status):
			# Case not visible, skip
			return

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
