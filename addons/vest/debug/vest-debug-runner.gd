extends "res://addons/vest/runner/vest-base-runner.gd"
class_name VestDebugRunner

var editor_interface: EditorInterface

var _debug_scene := preload("res://addons/vest/debug/debug-scene.tscn") as PackedScene

func run_script(script: Script) -> VestResult.Suite:
	# OVERRIDE
	return VestResult.Suite.new()

func run_glob(glob: String) -> VestResult.Suite:
	# OVERRIDE
	return VestResult.Suite.new()

func _run():
	# TODO: Figure out why not work
	var original_settings := _override_settings({
		"display/window/size/mode": DisplayServer.WINDOW_MODE_MINIMIZED
	})

	editor_interface.play_custom_scene(_debug_scene.resource_path)
	
	while editor_interface.is_playing_scene():
		await editor_interface.get_tree().create_timer(0.1).timeout

	_restore_settings(original_settings)

func _override_settings(overrides: Dictionary) -> Dictionary:
	var originals := {}

	for setting in overrides:
		originals[setting] = ProjectSettings.get_setting(setting)
		ProjectSettings.set(setting, overrides[setting])
		print("%s !> %s" % [setting, overrides[setting]])
	ProjectSettings.save()

	return originals

func _restore_settings(originals: Dictionary):
	for setting in originals:
		ProjectSettings.set(setting, originals[setting])
		print("%s ~> %s" % [setting, originals[setting]])
	ProjectSettings.save()
