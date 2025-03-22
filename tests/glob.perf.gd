extends VestTest

func get_suite_name() -> String:
	return "Vest.glob()"

func test_performance():
	var match_postfix := "-match"
	var match_chance := 0.15

	var rng := RandomNumberGenerator.new()
	rng.seed = 303

	# Create root directory
	var fs_root := "res://__vest_glob_perf/"
	if DirAccess.make_dir_recursive_absolute(fs_root) != OK:
		fail("Failed to create test directory: " + fs_root)
		return

	# Create random entries
	var entry_counts := [4, 4, 4, 8] as Array[int]
	var entries := generate_file_list(fs_root, entry_counts)

	for i in entries.size():
		var entry := entries[i]
		if rng.randf() < match_chance:
			entry += match_postfix
			entries[i] = entry

		DirAccess.make_dir_recursive_absolute(entry.get_base_dir())
		var fa := FileAccess.open(entry, FileAccess.WRITE)
		if fa == null:
			var error := error_string(FileAccess.get_open_error())
			Vest.message("Couldn't create file %s: %s" % [entry, error])
		else:
			fa.close()
	print("Generated file list:\n", "\n".join(entries))

	# Benchmark
	# Original: 50-70ms
	# Single directory deep: 13-15ms
	# Two directories deep: 3-4ms
	var pattern := fs_root + "0/0/*" + match_postfix
	benchmark("glob()", func():
		Vest.glob(pattern)
	).with_iterations(32).run()

	# Teardown
	cleanup(fs_root, entries)
	ok()

func generate_file_list(root: String, depths: Array[int]) -> Array[String]:
	var paths := [] as Array[String]
	var entry_count := depths.reduce(func(a, b): return a * b, 1) as int
	
	for i in entry_count:
		var indices := []
		var idx := i

		for depth in depths:
			indices.append(idx % depth)
			idx /= depth

		var path := root + "/".join(indices.map(func(it):
			return "%.2d" % [it]
		))

		paths.append(path)

	return paths

func cleanup(root: String, entries: Array[String]):
	for entry in entries:
		while true:
			DirAccess.remove_absolute(entry)
			var parent := entry.get_base_dir()
			if parent == entry or parent == root:
				break
			entry = parent

	DirAccess.remove_absolute(root)
