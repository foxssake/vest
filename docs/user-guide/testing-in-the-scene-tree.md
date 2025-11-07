# Testing in the scene tree

For certain heavier tests, you may want to put nodes into a scene tree and test
their interactions.

For this purpose, *vest* exposes a [SceneTree] that can be used for testing.
You can access it by calling `Vest.get_tree()`.

=== "define()"
    ```gdscript
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

    class TemporaryNode extends Node:
      var lifetime := 1.0

      func _process(delta):
        lifetime -= delta
        if lifetime <= 0.:
          queue_free()
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "SceneTree"

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
    ```

Do note that for now, this scene tree is not exclusive to your tests, it may
have other nodes in it. It is best to only clean up nodes created by the test,
and nothing else.

The main point of cleanup is not to avoid memory leaks - the nodes will be
freed once the test runner exists. The main reason for cleaning up nodes is to
not influence other tests. This way, you don't violate the [FIRST principles],
specifically the tests being *independent*.


[SceneTree]: https://docs.godotengine.org/en/stable/classes/class_scenetree.html
[FIRST principles]: https://software-tester.io/apply-first-principles-for-test-automation/
