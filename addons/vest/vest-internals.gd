extends Object

const GoToTestCommand := preload("res://addons/vest/commands/go-to-test-command.gd")
const CreateTestCommand := preload("res://addons/vest/commands/create-test-command.gd")

static func create_commands() -> Array[Node]:
	# TODO: Don't recreate if exists
	var commands := [
		GoToTestCommand.new(),
		CreateTestCommand.new()
	] as Array[Node]
	return commands
