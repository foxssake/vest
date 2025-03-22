extends Node
class_name VestGoToTestCommand

static var _instance: VestGoToTestCommand = null

static func find() -> VestGoToTestCommand:
	return _instance

func go_to_test():
	var interface := _get_editor_interface()
	var edited_script := interface.get_script_editor().get_current_script()
	
	if not edited_script:
		# No script is being edited
		return
	
	var script_path := edited_script.resource_path
	var script_filename := script_path.get_file()
	var patterns := [
		FilenamePattern.new("*.test.gd"),
		FilenamePattern.new("test_*.gd")
	] as Array[FilenamePattern]

	var target_filenames := get_search_filenames(script_filename, patterns)
	var hits := find_matching_scripts(script_path, target_filenames)

	if hits.size() == 1:
		# Single hit, navigate to script asap
		_get_editor_interface().edit_script(load(hits.front()))
	elif hits.size() > 1:
		# Multiple hits, let user choose which one to open
		show_popup(hits)

func get_search_filenames(script_filename: String, patterns: Array[FilenamePattern]) -> Array[String]:
	var result := [] as Array[String]

	# Check if currently open script is a test, in which case guess implementation's filename
	for pattern in patterns:
		if pattern.matches(script_filename):
			result.append(pattern.reverse(script_filename))

	# Currently open script is not a test, figure out possible test names
	if result.is_empty():
		result.append_array(patterns.map(func(it): return it.substitute(script_filename)))

	return result

func find_matching_scripts(script_path: String, search_filenames: Array[String]) -> Array[String]:
	var result := [] as Array[String]
	Vest.traverse_directory("res://", func(path: String):
		if path == script_path:
			return
		if path.get_file() not in search_filenames:
			return

		result.append(path)
	)

	return result

func show_popup(matching_script_paths: Array[String]):
	var popup := PopupMenu.new()
	popup.min_size = Vector2(0, 0)
	popup.size = Vector2(0, 0)
	for idx in range(matching_script_paths.size()):
		var script_path := matching_script_paths[idx]
		popup.add_icon_item(preload("res://addons/vest/icons/jump-to.svg"), script_path)
		popup.set_item_icon_max_width(popup.item_count - 1, VestUI.get_icon_size())

	_get_editor_interface().get_base_control().add_child(popup)
	popup.position = get_viewport().get_mouse_position()
	popup.visible = true
	popup.set_focused_item(0)

	popup.index_pressed.connect(func(idx: int):
		_get_editor_interface().edit_script(load(matching_script_paths[idx]))
	)

func _get_editor_interface() -> EditorInterface:
	return Vest._get_editor_interface()

func _ready():
	_instance = self
	_get_editor_interface().get_command_palette().add_command("Go to test", "vest/go-test", go_to_test, "Ctrl+T")

func _exit_tree():
	_get_editor_interface().get_command_palette().remove_command("vest/go-test")

func _shortcut_input(event):
	if event is InputEventKey:
		if event.is_command_or_control_pressed() and event.key_label == KEY_T and event.is_pressed():
			go_to_test()
			get_viewport().set_input_as_handled()
