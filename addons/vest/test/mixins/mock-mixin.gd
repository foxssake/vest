extends VestTestMixin

# TODO: Fail test case if there's unhandled calls

var _mock_generator := VestMockGenerator.new()
var _mock_handler := VestMockHandler.new()

# Maps Scripts to their mocked counterparts
var _mock_script_cache := {}

func mock(script: Script):
	var mocked_script := _get_mock_script(script)
	var mocked_object = mocked_script.new()

	_mock_handler.take_over(mocked_object)
	return mocked_object

func get_calls_of(method: Callable) -> Array[Array]:
	var result: Array[Array] = []

	for call_data in _mock_handler.get_calls():
		if call_data.method != method:
			continue
		result.append(call_data.args)

	return result

func when(method: Callable) -> AnswerBuilder:
	return AnswerBuilder.of(method, self)

func _get_mock_script(script: Script) -> Script:
	if _mock_script_cache.has(script):
		return _mock_script_cache.get(script)
	else:
		var mocked_script := _mock_generator.generate_mock_script(script)
		_mock_script_cache[script] = mocked_script
		return mocked_script

class AnswerBuilder:
	var test
	var args: Array = []
	var method: Callable

	func with_args(p_args: Array) -> AnswerBuilder:
		args = p_args
		return self

	func then_answer(p_answer_method: Callable) -> void:
		var answer := VestMockDefs.Answer.new()
		answer.expected_method = method
		answer.expected_args = args
		answer.answer_method = p_answer_method

		test._mock_handler.add_answer(answer)

	func then_return(p_answer_value: Variant) -> void:
		var answer := VestMockDefs.Answer.new()
		answer.expected_method = method
		answer.answer_value = p_answer_value
		answer.expected_args = args

		test._mock_handler.add_answer(answer)

	static func of(p_method: Callable, p_test):
		var builder := AnswerBuilder.new()
		builder.method = p_method
		builder.test = p_test
		return builder
