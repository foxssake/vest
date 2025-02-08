@tool
extends EditorPlugin

var bottom_control: VestUI

func _enter_tree():
	bottom_control = (preload("res://addons/vest/ui/vest-ui.tscn") as PackedScene).instantiate() as VestUI
	resource_saved.connect(bottom_control.handle_resource_saved)

	add_control_to_bottom_panel(bottom_control, "Vest")

func _exit_tree():
	resource_saved.disconnect(bottom_control.handle_resource_saved)
	remove_control_from_bottom_panel(bottom_control)
	bottom_control.queue_free()
