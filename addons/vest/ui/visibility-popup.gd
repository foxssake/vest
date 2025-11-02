@tool
extends PopupPanel

@onready var _container := %"Statuses Container" as Control
@onready var _all_button := %"All Button" as Button
@onready var _none_button := %"None Button" as Button

var _visibilities: Dictionary = {}

signal on_change()

func get_visibility_for(status: int) -> bool:
	return _visibilities.get(status, true)

func _init() -> void:
	# Default visibility to true
	for status in range(VestResult.TEST_MAX):
		_visibilities[status] = true

func _ready() -> void:
	_render()
	_all_button.pressed.connect(_show_all)
	_none_button.pressed.connect(_hide_all)

func _show_all() -> void:
	for status in _visibilities.keys():
		_visibilities[status] = true
	_render()
	on_change.emit()

func _hide_all() -> void:
	for status in _visibilities.keys():
		_visibilities[status] = false
	_render()
	on_change.emit()

func _render() -> void:
	if _container.get_child_count() != _visibilities.size():
		# Remove children
		for child in _container.get_children():
			child.queue_free()

		for status in _visibilities.keys():
			var checkbox := CheckBox.new()
			checkbox.toggle_mode = true
			checkbox.text = VestResult.get_status_string(status).capitalize()
			checkbox.icon = VestUI.get_status_icon(status)
			checkbox.expand_icon = true

			checkbox.pressed.connect(func():
				_visibilities[status] = not _visibilities[status]
				_render()
				on_change.emit()
			)

			_container.add_child(checkbox)

	# Update checkbox statuses
	for idx in range(_container.get_child_count()):
		var status := _visibilities.keys()[idx] as int
		var checkbox := _container.get_child(idx) as CheckBox
		checkbox.set_pressed_no_signal(_visibilities[status])
