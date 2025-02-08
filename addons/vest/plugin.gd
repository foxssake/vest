@tool
extends EditorPlugin

var bottom_control: VestUI

func _enter_tree():
	bottom_control = _create_ui()
#	resource_saved.connect(bottom_control.handle_resource_saved)
#	resource_saved.connect(_refresh_ui)

	add_control_to_bottom_panel(bottom_control, "Vest")

func _exit_tree():
#	resource_saved.disconnect(bottom_control.handle_resource_saved)
#	resource_saved.disconnect(_refresh_ui)
	remove_control_from_bottom_panel(bottom_control)
	bottom_control.queue_free()

func _refresh_ui(__):
	if bottom_control:
		remove_control_from_bottom_panel(bottom_control)
		bottom_control.queue_free()

	bottom_control = _create_ui()
	add_control_to_bottom_panel(bottom_control, "Vest")

	resource_saved.connect(bottom_control.handle_resource_saved)

func _create_ui() -> VestUI:
	return (preload("res://addons/vest/ui/vest-ui.tscn") as PackedScene).instantiate() as VestUI
