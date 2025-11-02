extends SceneTree

var _process_tick_time := 1. / 60.
var _physics_tick_time := 1. / 60.
var _physics_rest := 0.

var _is_active := true

func _init(physics_fps: float = 60., process_fps: float = 60.):
	_process_tick_time = 1. / process_fps
	_physics_tick_time = 1. / physics_fps
	_physics_rest = _physics_tick_time

func ready_nodes() -> void:
	_do_ready()

func tick() -> void:
	var dt := _process_tick_time
	_do_ready()
	_do_process(dt)
	_physics_tick(dt)

func run(time: float) -> void:
	while time > 0.0 and _is_active:
		var dt := _process_tick_time
		_do_ready()
		_do_process(dt)
		_physics_tick(dt)

		time -= dt

func _physics_tick(dt: float) -> void:
	_physics_rest -= dt
	if _physics_rest <= 0.:
#		_is_active = _is_active && not _physics_process(_physics_tick_time)
		_do_physics_process(_physics_tick_time)
		_physics_rest += _physics_tick_time

func _do_ready() -> void:
	_walk_tree(func(node: Node):
		if not node.is_node_ready():
			node.notification(Node.NOTIFICATION_READY)
	)

func _do_process(dt: float) -> void:
	_walk_tree(func(node: Node):
		if node.is_processing():
			if node.has_method("_process"):
				node._process(dt)
			else:
				node.notification(Node.NOTIFICATION_PROCESS)
	)

func _do_physics_process(dt: float) -> void:
	_walk_tree(func(node: Node):
		if node.has_method("_physics_process"):
			node._physics_process(dt)
		else:
			node.notification(Node.NOTIFICATION_PHYSICS_PROCESS)
	)

func _walk_tree(callback: Callable) -> void:
	var queue := [root]
	while not queue.is_empty():
		var at := queue.pop_front() as Node
		callback.call(at)
		queue = at.get_children(true) + queue
