extends Object
class_name Vest

## Utility singleton for running tests.
##
## @tutorial(Printing custom messages): https://foxssake.github.io/vest/latest/user-guide/printing-custom-messages/

const Icons := preload("res://addons/vest/icons/vest-icons.gd")
const Timeout := preload("res://addons/vest/timeout.gd")

const ValueMeasure := preload("res://addons/vest/measures/value-measure.gd")
const SumMeasure := preload("res://addons/vest/measures/sum-measure.gd")
const AverageMeasure := preload("res://addons/vest/measures/average-measure.gd")
const MinMeasure := preload("res://addons/vest/measures/min-measure.gd")
const MaxMeasure := preload("res://addons/vest/measures/max-measure.gd")

const __ := preload("res://addons/vest/vest-internals.gd")

const NEW_TEST_MIRROR_DIR_STRUCTURE := 0
const NEW_TEST_NEXT_TO_SOURCE := 1
const NEW_TEST_IN_ROOT := 2

static var _messages: Array[String] = []
static var _scene_tree: SceneTree
static var _editor_interface_provider: Callable

## Add a custom message to the current test.
## [br][br]
## Will be included in the test report.
static func message(p_message: String):
	_messages.append(p_message)

## Wait for [param condition] to be true, or until timeout.
## [br][br]
## This method will start a loop, each time waiting [param interval] seconds.
## On each iteration, [param condition] is called. If its result is true, or the
## [param duration] has been exceeded, the loop stops.
## [br][br]
## If [param duration] is 0., the loop may run infinitely, without timeout.
## [br][br]
## Returns [constant OK] if [param condition] was true.[br]
## Returns [constant ERR_TIMEOUT] if [param duration] was exceeded.[br]
## Returns [constant ERR_UNAVAILABLE] if no [SceneTree] is available.
static func until(condition: Callable, duration: float = 5., interval: float = 0.0) -> Error:
	var deadline := time() + duration

	if not _scene_tree:
		push_warning("Missing reference to SceneTree, will return immediately!")
		return ERR_UNAVAILABLE

	while time() < deadline:
		if condition.call():
			return OK

		if is_zero_approx(duration): await _scene_tree.process_frame
		else: await _scene_tree.create_timer(interval).timeout

	return ERR_TIMEOUT

# TODO: Docs
static func timeout(duration: float = 5.0, interval: float = 0.0) -> Timeout:
	return Timeout.new(duration, interval, _scene_tree)

## Wait for [param duration] seconds.
## [br][br]
## Waiting for 0 seconds will wait until the next
## [signal SceneTree.process_frame].
## [br][br]
## Returns [constant OK] on success.[br]
## Returns [constant ERR_UNAVAILABLE] if no [SceneTree] is available.
static func sleep(duration: float = 0.) -> Error:
	if not _scene_tree:
		push_warning("Missing reference to SceneTree, will return immediately!")
		return ERR_UNAVAILABLE

	if is_zero_approx(duration): await _scene_tree.process_frame
	else: await _scene_tree.create_timer(duration).timeout
	return OK

# TODO: Docs
static func get_runner_timeout() -> float:
	return ProjectSettings.get_setting("vest/runner_timeout", 8.0)

# TODO: Docs
static func get_sources_root() -> String:
	return ProjectSettings.get_setting("vest/sources_root", "res://")

# TODO: Docs
static func get_tests_root() -> String:
	return ProjectSettings.get_setting("vest/tests_root", "res://tests/")

# TODO: Docs
static func get_test_name_patterns() -> Array[FilenamePattern]:
	# TODO: Memoize
	var pattern_strings := ProjectSettings.get_setting("vest/test_name_patterns") as PackedStringArray
	var patterns := [] as Array[FilenamePattern]
	patterns.assign(Array(pattern_strings).map(func(it): return FilenamePattern.new(it)))

	return patterns

# TODO: Docs
static func get_new_test_location_preference() -> int:
	return ProjectSettings.get_setting("vest/new_test_location", NEW_TEST_MIRROR_DIR_STRUCTURE)

## Get the current time, in seconds.
## [br][br]
## Used for benchmarking and waiting [method until] a condition becomes true.
static func time() -> float:
	return Time.get_unix_time_from_system()

# TODO: Docs
static func traverse_directory(directory: String, visitor: Callable, max_iters: int = 131072) -> void:
	var da := DirAccess.open(directory)
	da.include_navigational = false

	var dir_queue := [directory]
	var dir_history := []

	# Put an upper limit on iterations, so we can't run into a runaway loop
	for i in max_iters:
		if dir_queue.is_empty():
			break

		var dir_at := dir_queue.pop_front() as String
		da.change_dir(dir_at)
		dir_history.append(dir_at)

		# Add directories to queue
		for dir_name in da.get_directories():
			var dir := path_join(da.get_current_dir(), dir_name)
			if not dir_history.has(dir) and not dir_queue.has(dir):
				dir_queue.append(dir)

		# Visit files
		for file_name in da.get_files():
			var file := path_join(da.get_current_dir(), file_name)
			visitor.call(file)

# TODO: Docs
static func glob(pattern: String, max_iters: int = 131072) -> Array[String]:
	if pattern.is_empty(): return []
	var results: Array[String] = []

	var first_glob_index := mini(
		(pattern.find("?") + pattern.length()) % pattern.length(),
		(pattern.find("*") + pattern.length()) % pattern.length()
	)
	var root := (
		pattern.get_base_dir()
		if first_glob_index < 0 else
		pattern.substr(0, first_glob_index).get_base_dir()
	)

	traverse_directory(root, func(path: String):
		if path.match(pattern):
			results.append(path)
	, max_iters)

	return results

# TODO: Remove - there's String.path_join
static func path_join(a: String, b: String) -> String:
	if a.ends_with("/"):
		return a + b
	else:
		return a + "/" + b

static func _clear_messages():
	_messages.clear()

static func _get_messages() -> Array[String]:
	return _messages.duplicate()

static func _register_scene_tree(scene_tree: SceneTree):
	_scene_tree = scene_tree

static func _get_editor_interface() -> EditorInterface:
	return _editor_interface_provider.call()

static func _register_editor_interface_provider(provider: Callable):
	_editor_interface_provider = provider
