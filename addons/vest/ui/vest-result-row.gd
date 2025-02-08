@tool
extends Control
class_name VestResultRow

var _result: VestResult.Case

func set_result(result: VestResult.Case):
	_result = result
	update()

func update():
	pass
