extends VestTest

func get_suite_name():
	return "Generators"

func test_generator():
	await Vest.sleep(.2)
	
	var generator := Generator.of(func(gen: Callable):
		print("Generator started!")
		await gen.call(1)
		await Vest.sleep(0.1)
		await gen.call(2)
		await Vest.sleep(0.1)
		await gen.call(3)
	)
	
	var values := []
	for __ in generator:
		var val = await __
		values.append(val)
		print(val)
	
	expect_equal(values, [1, 2, 3])

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
		_run()
	
	func _generate(value: Variant) -> void:
		_queued_value = value
		_status = PENDING
		(func(): _on_push.emit()).call_deferred()
		await _on_pull
	
	func _run() -> void:
		_status = ACTIVE
		await _callable.call(_generate)
		_status = FINISHED
		
		_queued_value = null
	
	func _iter_init(arg) -> bool:
		return _status != FINISHED

	func _iter_next(arg) -> bool:
		_on_pull.emit()
		return _status != FINISHED

	func _iter_get(arg) -> Variant:
		if _status == PENDING:
			await _on_push
		return _queued_value

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
