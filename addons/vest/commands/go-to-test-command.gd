extends Node
class_name VestGoToTestCommand

static var _instance: VestGoToTestCommand = null

static func find() -> VestGoToTestCommand:
	return _instance

func _ready():
	_instance = self
	get_editor_interface().get_command_palette().add_command("Go to test", "vest/go-test", go_to_test, "Ctrl+T")

func _exit_tree():
	get_editor_interface().get_command_palette().remove_command("vest/go-test")

func _shortcut_input(event):
	if event is InputEventKey:
		if event.is_command_or_control_pressed() and event.key_label == KEY_T and event.is_pressed():
			go_to_test()
			get_viewport().set_input_as_handled()

func go_to_test():
	print("Where test?")
	var interface := get_editor_interface()
	var edited_script := interface.get_script_editor().get_current_script()
	
	if not edited_script:
		print("No script open!")
		return
	
	var script_path := edited_script.resource_path
	var script_filename := script_path.get_file()
	var target_filenames := [
		script_filename,
		script_filename.get_basename() + ".test.gd",
		"test_" + script_filename,
		script_filename.replace(".test.gd", ".gd"),
		script_filename.replace("test_", "") # TODO: Only remove if starts with
	]
	
	print("Script: %s / %s" % [script_filename, script_path])
	print("Looking for: %s" % [target_filenames])
	
	var hits := [] as Array[String]
	Vest.traverse_directory("res://", func(path: String):
		if path == script_path:
			return
		if path.get_file() not in target_filenames:
			return
		# TODO: Consider checking if script extends VestTest in some way
		hits.append(path)
	)
	
	print("Found scripts: %s" % [hits])
	if hits.size() == 1:
		print("Navigating to: %s" % [hits.front()])
		get_editor_interface().edit_script(load(hits.front()))
		return

	# Create popup with options
	var popup := PopupMenu.new()
	popup.min_size = Vector2(0, 0)
	popup.size = Vector2(0, 0)
	for idx in range(hits.size()):
		var hit := hits[idx]
		var accel := (KEY_1 + idx) if idx < 9 else 0
		popup.add_icon_item(preload("res://addons/vest/icons/run.svg"), hit, -1, accel)
		popup.set_item_icon_max_width(popup.item_count - 1, 16)
	popup.add_icon_item(preload("res://addons/vest/icons/lightbulb.svg"), "Create new test", -1, KEY_C)

	get_editor_interface().get_base_control().add_child(popup)
	popup.position = get_viewport().get_mouse_position()
	popup.visible = true
	popup.set_focused_item(0)
	print("Spawned popup %s" % [popup])

	popup.index_pressed.connect(func(idx: int):
		if idx < hits.size():
			get_editor_interface().edit_script(load(hits[idx]))
		else:
			print("Create new script!")
	)

func get_editor_interface() -> EditorInterface:
	return Vest._get_editor_interface()
