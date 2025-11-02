extends VestTest

func get_suite_name():
	return "TestingTree"

func suite() -> void:
	test("should call ready", func():
		var tree := Vest.TestingTree.new()
		var node := TestNode.new()

		tree.root.add_child(node)
		tree.tick()

		expect(node.is_ready)
	)

	test("should run for time", func():
		var tree := Vest.TestingTree.new()
		var node := TestNode.new()
		tree.root.add_child(node)

		# Run scene
		tree.run(1.0)

		expect(absf(node.process_time - 1.) < 0.01, "Node wasn't processed!")
		expect(absf(node.physics_time - 1.) < 0.01, "Node wasn't physics simulated!")
	)

class TestNode extends Node:
	var process_time := 0.
	var physics_time := 0.
	var is_ready := false

	func _ready() -> void:
		is_ready = true

	func _process(dt: float) -> void:
		process_time += dt

	func _physics_process(dt: float) -> void:
		physics_time += dt
