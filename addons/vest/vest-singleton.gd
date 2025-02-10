extends Object
class_name Vest

static var _messages: Array[String] = []
static var _scene_tree: SceneTree

static func print(message: String):
	_messages.append(message)

static func until(condition: Callable, timeout: float = 5., interval: float = 0.2) -> Error:
	if not _scene_tree:
		push_warning("Missing reference to SceneTree, will return immediately!")
		return ERR_UNAVAILABLE

	while timeout >= 0.:
		if condition.call():
			return OK
		await _scene_tree.create_timer(interval).timeout
		timeout -= interval

	return ERR_TIMEOUT

static func _clear_messages():
	_messages.clear()

static func _get_messages() -> Array[String]:
	return _messages.duplicate()

static func _register_scene_tree(scene_tree: SceneTree):
	_scene_tree = scene_tree
