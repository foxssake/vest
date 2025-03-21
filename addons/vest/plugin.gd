@tool
extends EditorPlugin

var bottom_control: Control

const SETTINGS = [
	{
		"name": "vest/general/test_glob",
		"value": "res://*.test.gd",
		"type": TYPE_STRING
	},
	{
		"name": "vest/general/debug_port",
		"value": 59432,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_RANGE,
		"hint_string": "0,65535"
	}
]

func _enter_tree():
	Vest._register_scene_tree(get_tree())
	Vest._register_editor_interface(get_editor_interface())

	bottom_control = (preload("res://addons/vest/ui/vest-ui.tscn") as PackedScene).instantiate()
	resource_saved.connect(bottom_control.handle_resource_saved)

	add_control_to_bottom_panel(bottom_control, "Vest")

	add_settings(SETTINGS)
	
	get_editor_interface().get_command_palette().add_command("Go to test", "vest/go-test", func():
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
			script_filename.replace(".test.gd", ".gd")
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
	, "Ctrl+T")

func _exit_tree():
	resource_saved.disconnect(bottom_control.handle_resource_saved)
	remove_control_from_bottom_panel(bottom_control)
	bottom_control.queue_free()

	remove_settings(SETTINGS)
	
	get_editor_interface().get_command_palette().remove_command("vest/go-test")

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
