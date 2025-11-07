extends VestTest

func get_suite_name() -> String:
	return "SceneTree"

func suite():
	test("node should vanish", func():
		var node := TemporaryNode.new()
		Vest.get_tree().root.add_child(node)
		
		await Vest.sleep(0.5)
		expect(is_instance_valid(node))
		
		await Vest.sleep(0.5)
		expect_not(is_instance_valid(node))
	)

func test_node_should_vanish():
	var node := TemporaryNode.new()
	Vest.get_tree().root.add_child(node)
	
	await Vest.sleep(0.5)
	expect(is_instance_valid(node))
	
	await Vest.sleep(0.5)
	expect_not(is_instance_valid(node))

class TemporaryNode extends Node:
	var lifetime := 1.0

	func _process(delta):
		lifetime -= delta
		if lifetime <= 0.:
			queue_free()
