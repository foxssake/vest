extends Object
class_name VestMockDefs

class Answer:
	var expected_method: Callable
	var expected_args: Array = []
	var answer_value: Variant
	var answer_method: Callable
	
	func get_specificity() -> int:
		return expected_args.size()

	func is_answering(method: Callable, args: Array) -> bool:
		if method != expected_method:
			return false
		if expected_args.is_empty():
			return true
		if args.size() != expected_args.size():
			return false
		if args == expected_args:
			return true
		if str(args) == str(expected_args):
			# Do a lenient check, so users don't trip on unexpected diffs, like
			# [2, 4] != [2., 4.]
			return true
		return false

	func get_answer(args: Array) -> Variant:
		if answer_method:
			answer_method.get_bound_arguments_count()
			return answer_method.call(args)
		else:
			return answer_value

class Call:
	var method: Callable
	var args: Array = []
