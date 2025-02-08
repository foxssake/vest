extends Object
class_name VestMixins

static func get_mixins() -> Array[Script]:
	var result: Array[Script] = []
	result.assign((VestTest.new()).__vest_mixins)
	return result

static func add_mixin(mixin: Script):
	var active_mixins := get_mixins()
	if not active_mixins.has(mixin):
		active_mixins.append(mixin)
		_generate_mixin_chain(active_mixins)

static func remove_mixin(mixin: Script):
	var active_mixins := get_mixins()
	if active_mixins.has(mixin):
		active_mixins.erase(mixin)
		_generate_mixin_chain(active_mixins)

static func _generate_mixin_chain(mixins: Array[Script]):
	# Generate mixin chain
	var mixin_chain: Array[Script] = []
	mixin_chain.append(_get_test_base())
	mixin_chain.append_array(_get_builtin_mixins())

	var active_mixins: Array[Script] = []

	for mixin_script in mixins:
		if not mixin_script:
			# Not script?
			continue

		if mixin_chain.has(mixin_script):
			# Don't include the same mixin twice
			continue

		mixin_chain.append(mixin_script)
		active_mixins.append(mixin_script)

	mixin_chain.append(VestTest)

	# Generate chain
	_clean_mixin_directory()
	DirAccess.make_dir_recursive_absolute(_get_mixin_directory())
	var extends_pattern := RegEx.create_from_string("^extends.*")

	for i in range(1, mixin_chain.size()):
		var parent_script := mixin_chain[i - 1]
		var target_script := mixin_chain[i]

		var parent_path := parent_script.resource_path
		var target_path := target_script.resource_path

		if i != 1:
			parent_path = _get_generated_mixin_path(parent_script, i - 1)
		if i != mixin_chain.size() - 1:
			target_path = _get_generated_mixin_path(target_script, i)

		# Generate source
		var target_source := target_script.source_code
		var script_header := (
			"# This file is generated by Vest!\n" +
			"# Do not modify!\n" +
			"extends \"%s\"\n\n" % [parent_path])

		target_source = extends_pattern.sub(target_source, "", true)
		if target_script != VestTest:
			target_source = script_header + target_source
		else:
			target_source = script_header
			target_source += "class_name VestTest\n\n"

			var mixin_fragments = active_mixins\
				.map(func(it): return it.resource_path)\
				.map(func(it): return "preload(\"%s\")" % it)

			mixin_fragments = ", ".join(mixin_fragments)
			target_source += "var __vest_mixins: Array = [%s]" % [mixin_fragments]

		var target_file := FileAccess.open(target_path, FileAccess.WRITE)
		target_file.store_string(target_source)
		target_file.close()

static func _get_generated_mixin_name(script: Script, idx: int) -> String:
	return "%d-%x.gd" % [idx, hash(script.resource_path.get_file())]

static func _get_generated_mixin_path(script: Script, idx: int) -> String:
	return _get_mixin_directory() + _get_generated_mixin_name(script, idx)

static func _get_builtin_mixins() -> Array[Script]:
	return [
		preload("res://addons/vest/test/mixins/gather-suite-mixin.gd"),
		preload("res://addons/vest/test/mixins/assert-mixin.gd"),
		preload("res://addons/vest/test/mixins/mock-mixin.gd")
	]

static func _get_mixin_directory() -> String:
	return "res://addons/vest/_generated-mixins/"

static func _clean_mixin_directory():
	for file in DirAccess.get_files_at(_get_mixin_directory()):
		DirAccess.remove_absolute(_get_mixin_directory() + file)

static func _get_test_base() -> Script:
	return preload("res://addons/vest/test/vest-test-base.gd") as Script
