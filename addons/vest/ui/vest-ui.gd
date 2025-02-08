@tool
extends Control
class_name VestUI

@onready var run_all_button := %"Run All Button" as Button
@onready var run_on_save_checkbox := %"Run On Save CheckBox" as CheckBox
@onready var clear_button := %"Clear Button" as Button
@onready var results_tree := %"Results Tree" as Tree
@onready var summary_label := %"Tests Summary Label" as Label
@onready var results_label := %"Tests Result Label" as Label

var _run_on_save: bool = false

func handle_resource_saved(resource: Resource):
	if not resource is Script or not visible:
		return

	if _run_on_save:
		run_all()

func run_all():
	var runner := VestDaemonRunner.new()
	get_tree().root.add_child(runner)

	clear_results()

	var test_start := _time()
	var results := await runner.run_glob("res://*.test.gd") # TODO: Support custom glob
	var test_duration := _time() - test_start

	var success_row = load("res://addons/vest/ui/success-row.tscn") as PackedScene
	var fail_row = load("res://addons/vest/ui/fail-row.tscn") as PackedScene

	# Render individual results
	_render_result(results, results_tree)
	var item := results_tree.create_item()

	# Render summaries
	summary_label.text = "Ran %d tests in %.2fms" % [results.size(), test_duration * 1000.]
	results_label.text = ("%s" % [results.get_aggregate_status_string()]).capitalize()

func clear_results():
	results_tree.clear()
	summary_label.text = ""
	results_label.text = ""

func _ready():
	run_all_button.pressed.connect(run_all)
	run_on_save_checkbox.toggled.connect(func(toggled):
		_run_on_save = toggled
	)
	clear_button.pressed.connect(clear_results)

func _render_result(what: Object, tree: Tree, parent: TreeItem = null):
	if what is VestResult.Suite:
		var item := tree.create_item(parent)
		item.set_text(0, what.suite.name)
		item.set_text(1, what.get_aggregate_status_string().capitalize())

		for subsuite in what.subsuites:
			_render_result(subsuite, tree, item)
		for case in what.cases:
			_render_result(case, tree, item)
		for benchmark in what.benchmarks:
			_render_result(benchmark, tree, item)
	elif what is VestResult.Case:
		var item := tree.create_item(parent)
		item.set_text(0, what.case.description)
		item.set_text(1, what.get_status_string().capitalize())
	elif what is VestResult.Benchmark:
		var item := tree.create_item(parent)
		item.set_text(0, what.benchmark.description)
		item.set_collapsed_recursive(true)

		tree.create_item(item).set_text(0, "Duration: %.2fms" % [what.duration * 1000.])
		tree.create_item(item).set_text(0, "Iterations: %d" % [what.iterations])
	else:
		push_error("Rendering unknown object: %s" % [what])

func _time() -> float:
	return Time.get_unix_time_from_system() / 1000.
