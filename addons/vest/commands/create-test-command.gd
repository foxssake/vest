extends Node
class_name VestCreateTestCommand

static var _instance: VestCreateTestCommand = null

static func find() -> VestCreateTestCommand:
	return _instance

static func execute() -> void:
	if _instance:
		_instance.create_test()
	else:
		push_warning("No instance of Create Test command found!")

func create_test():
	var edited_script := _get_editor_interface().get_script_editor().get_current_script()

	if not edited_script:
		print("No script open!")
		_get_editor_interface().get_script_editor().open_script_create_dialog("VestTest", "")
		return

	var script_path := edited_script.resource_path
	var script_directory := script_path.get_base_dir()
	var script_filename := script_path.get_file()

	if Vest.get_test_name_patterns().any(func(it): return it.matches(script_filename)):
		# Script is already a test
		print("Script is test!")
		return

	var preferred_pattern := Vest.get_test_name_patterns()[0]
	var test_filename := preferred_pattern.substitute(script_filename)
	var test_path := script_directory + "/" + test_filename # TODO: Test root

	print("Create test at %s" % [test_path])
	_get_editor_interface().get_script_editor().open_script_create_dialog("VestTest", test_path)

func _get_editor_interface() -> EditorInterface:
	return Vest._get_editor_interface()

func _ready():
	_instance = self
