@tool
extends EditorPlugin

var bottom_control: VestUI

func _enter_tree():
	bottom_control = _create_ui()
	resource_saved.connect(bottom_control.handle_resource_saved)

	add_control_to_bottom_panel(bottom_control, "Vest")

func _exit_tree():
	resource_saved.disconnect(bottom_control.handle_resource_saved)
	remove_control_from_bottom_panel(bottom_control)
	bottom_control.queue_free()

func _create_ui() -> VestUI:
	var ui := (preload("res://addons/vest/ui/vest-ui.tscn") as PackedScene).instantiate() as VestUI
	ui.on_navigate.connect(func(file, line):
		if file:
			get_editor_interface().edit_script(load(file), line)
	)
	return ui
