extends Object
class_name Vest

static var _messages: Array[String] = []
static var _scene_tree: SceneTree
static var _editor_interface: EditorInterface

static func message(p_message: String):
	_messages.append(p_message)

static func until(condition: Callable, timeout: float = 5., interval: float = 0.0) -> Error:
	var deadline := time() + timeout

	if not _scene_tree:
		push_warning("Missing reference to SceneTree, will return immediately!")
		return ERR_UNAVAILABLE

	while time() < deadline:
		if condition.call():
			return OK

		if is_zero_approx(timeout): await _scene_tree.process_frame
		else: await _scene_tree.create_timer(interval).timeout

	return ERR_TIMEOUT

static func set_test_glob(glob: String):
	ProjectSettings.set_setting("vest/general/test_glob", glob)

static func get_test_glob() -> String:
	return ProjectSettings.get_setting("vest/general/test_glob", "res://*.test.gd")

static func get_debug_port() -> int:
	return ProjectSettings.get_setting("vest/general/debug_port", 59432)

static func time() -> float:
	return Time.get_unix_time_from_system()

static func _clear_messages():
	_messages.clear()

static func _get_messages() -> Array[String]:
	return _messages.duplicate()

static func _register_scene_tree(scene_tree: SceneTree):
	_scene_tree = scene_tree

static func _get_editor_interface() -> EditorInterface:
	return _editor_interface

static func _register_editor_interface(editor_interface: EditorInterface):
	_editor_interface = editor_interface
