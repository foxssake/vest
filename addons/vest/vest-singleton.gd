extends Object
class_name Vest

static var _messages: Array[String] = []
static var _scene_tree: SceneTree

static func print(message: String):
	_messages.append(message)

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

static func time() -> float:
	return Time.get_unix_time_from_system()

static func _clear_messages():
	_messages.clear()

static func _get_messages() -> Array[String]:
	return _messages.duplicate()

static func _register_scene_tree(scene_tree: SceneTree):
	_scene_tree = scene_tree
