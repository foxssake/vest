@tool
extends EditorPlugin
class_name VestEditorPlugin

var bottom_control: VestUI

const SETTINGS = [
	{
		"name": "vest/general/test_glob",
		"value": "res://*.test.gd",
		"type": TYPE_STRING
	},
	{
		"name": "vest/runner/debug_port",
		"value": 0,
		"type": TYPE_INT
	}
]

static func set_test_glob(glob: String):
	ProjectSettings.set_setting("vest/general/test_glob", glob)

static func get_test_glob() -> String:
	return ProjectSettings.get_setting("vest/general/test_glob", "res://*.test.gd")

static func _set_debug_port(port: int):
	ProjectSettings.set_setting("vest/runner/debug_port", port)

static func _get_debug_port() -> int:
	return ProjectSettings.get_setting("vest/runner/debug_port", -1)

func _enter_tree():
	print("Test glob: %s" % [ProjectSettings.get_setting("vest/general/test_glob", null)])
	bottom_control = _create_ui()
	resource_saved.connect(bottom_control.handle_resource_saved)

	add_control_to_bottom_panel(bottom_control, "Vest")

	add_settings(SETTINGS)

func _exit_tree():
	resource_saved.disconnect(bottom_control.handle_resource_saved)
	remove_control_from_bottom_panel(bottom_control)
	bottom_control.queue_free()

	remove_settings(SETTINGS)

func _create_ui() -> VestUI:
	var ui := (preload("res://addons/vest/ui/vest-ui.tscn") as PackedScene).instantiate() as VestUI

	ui.on_navigate.connect(func(file, line):
		if file:
			get_editor_interface().edit_script(load(file), line)
	)

	ui.on_debug.connect(func():
#		var debugger := _create_debugger()
#		debugger.editor_interface = get_editor_interface()

		var runner := VestDebugRunner.new()
		add_child(runner)
		runner.editor_interface = get_editor_interface()
		
#		add_debugger_plugin(debugger)
		await runner._run()
#		remove_debugger_plugin(debugger)

		runner.queue_free()
	)

	return ui

func _create_debugger() -> EditorDebuggerPlugin:
	return load("res://addons/vest/debug/vest-debugger-plugin.gd").new()

func add_settings(settings: Array):
	for setting in settings:
		add_setting(setting)

func add_setting(setting: Dictionary):
	if ProjectSettings.has_setting(setting.name):
		return

	ProjectSettings.set_setting(setting.name, setting.value)
	ProjectSettings.set_initial_value(setting.name, setting.value)
	ProjectSettings.add_property_info({
		"name": setting.get("name"),
		"type": setting.get("type"),
		"hint": setting.get("hint", PROPERTY_HINT_NONE),
		"hint_string": setting.get("hint_string", "")
	})

func remove_settings(settings: Array):
	for setting in settings:
		remove_setting(setting)

func remove_setting(setting: Dictionary):
	if not ProjectSettings.has_setting(setting.name):
		return

	ProjectSettings.clear(setting.name)
