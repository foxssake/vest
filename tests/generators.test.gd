extends VestTest

func get_suite_name():
	return "Generators"

func test_generator():
	var generator := Generator.of(func(gen: Callable):
		print("Generator started!")
		print("await gen.call(1)"); await gen.call(1)
		print("await gen.call(2)"); await gen.call(2)
		print("await gen.call(3)"); await gen.call(3)
	)
	
	var values := []
	for val in generator:
		values.append(await val)
	
	expect_equal(values, [1, 2, 3, null])

func test_iterator():
	var iterator := ThinkingIterable.new()
	for i in iterator:
		print(await i)
	ok()

class Generator:
	var _callable: Callable
	var _queued_value: Variant
	var _status: int = PENDING
	
	enum {
		PENDING,
		ACTIVE,
		FINISHED
	}
	
	signal _on_pull()
	signal _on_push()
	
	func _init(p_callable: Callable):
		_callable = p_callable
	
	func _generate(value: Variant) -> void:
		print("_generate() / Queued value: %s" % [value]); _queued_value = value
		print("_generate() / _on_push.emit()"); (func(): _on_push.emit()).call_deferred()
		print("_generate() / await _on_pull"); await _on_pull
		print("_generate() / _generate(%s) finished" % [value])
	
	func _run() -> void:
		print("_run() / _status = ACTIVE"); _status = ACTIVE
		print("_run() / await _callable.call()"); await _callable.call(_generate)
		print("_run() / _status = FINISHED"); _status = FINISHED
		
		print("_run() / _queued_value = null"); _queued_value = null
		print("_run() / _on_push.emit()"); (func(): _on_push.emit()).call_deferred()
	
	func _iter_init(arg) -> bool:
		return _status == PENDING

	func _iter_next(arg) -> bool:
		return _status != FINISHED

	func _iter_get(arg) -> Variant:
		return await get_value()
	
	func get_value() -> Variant:
		print("get_value()")
		match _status:
			PENDING:
				print("get_value() / PENDING / _run()"); _run()
				print("get_value() / PENDING / await _on_push"); await _on_push
				print("get_value() / PENDING / return %s" % [_queued_value]); return _queued_value
			ACTIVE:
				print("get_value() / ACTIVE / _on_pull.emit()"); _on_pull.emit()
				print("get_value() / ACTIVE / await _on_push"); await _on_push
				print("get_value() / ACTIVE / Resulting state: %s" % [_status]);
				print("get_value() / ACTIVE / return %s" % [_queued_value]); return _queued_value
			_:
				return null
	
	static func of(p_callable: Callable) -> Generator:
		return Generator.new(p_callable)

class ThinkingIterable:
	var _iters := 0

	func _iter_init(arg):
		_iters = 0
		return true

	func _iter_next(arg):
		_iters += 1
		return _iters <= 3

	func _iter_get(arg):
		await Vest.sleep(0.1)
		return _iters
