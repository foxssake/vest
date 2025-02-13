@tool
extends EditorPlugin

var bottom_control: Control

const SETTINGS = [
	{
		"name": "vest/general/test_glob",
		"value": "res://*.test.gd",
		"type": TYPE_STRING
	}
]

func _enter_tree():
	Vest._register_scene_tree(get_tree())

	bottom_control = _create_ui()
	resource_saved.connect(bottom_control.handle_resource_saved)

	add_control_to_bottom_panel(bottom_control, "Vest")

	add_settings(SETTINGS)

func _exit_tree():
	resource_saved.disconnect(bottom_control.handle_resource_saved)
	remove_control_from_bottom_panel(bottom_control)
	bottom_control.queue_free()

	remove_settings(SETTINGS)

func _create_ui() -> Control:
	var ui := (preload("res://addons/vest/ui/vest-ui.tscn") as PackedScene).instantiate() as Control

	ui.on_navigate.connect(func(file, line):
		if file:
			get_editor_interface().edit_script(load(file), line)
	)

	ui.on_debug.connect(func():
		get_editor_interface().play_custom_scene(preload("res://addons/vest/debug/vest-debug-scene.tscn").resource_path)
	)

	return ui

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
