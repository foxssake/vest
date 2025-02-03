extends RefCounted
class_name VestMockHandler

var _answers: Array[VestMockDefs.Answer] = []
var _calls: Array[VestMockDefs.Call] = []
var _unhandled_calls: Array[VestMockDefs.Call] = []

func take_over(what: Object):
	what.__vest_mock_handler = self

func add_answer(answer: VestMockDefs.Answer):
	_answers.append(answer)

func _handle(method: Callable, args: Array):
	var call := VestMockDefs.Call.new()
	call.method = method
	call.args = args

	var possible_answers = _answers\
		.filter(func(it): return it.is_answering(method, args))
	possible_answers.sort_custom(func(a, b): return a.get_specificity() > b.get_specificity())
	
	if possible_answers.is_empty():
		_unhandled_calls.append(call)
		return

	var answer := possible_answers.front() as VestMockDefs.Answer
	_calls.append(call)
	return answer.get_answer(args)
