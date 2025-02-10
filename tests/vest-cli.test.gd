extends VestTest

func suite_params():
	define("CLI Params", func():

		test("should serialize to args", func():
			# Given
			var params := VestCLI.Params.new()
			params.run_file = "foo.gd"
			params.run_glob = "*.test.gd"
			params.report_format = "tap"
			params.report_file = "vest-report.log"
			params.host = "127.0.0.1"
			params.port = 37852

			var expected: Array[String] = [
				"--vest-file", "foo.gd",
				"--vest-glob", "*.test.gd",
				"--vest-report-format", "tap",
				"--vest-report-file", "vest-report.log",
				"--vest-host", "127.0.0.1",
				"--vest-port", "37852"
			]

			# When
			var actual := params.to_args()

			# Then
			expect_equal(actual, expected)
		)
		
		test("should parse", func():
			# Given
			var args: Array[String] = [
				"--vest-file", "foo.gd",
				"--vest-glob", "*.test.gd",
				"--vest-report-format", "tap",
				"--vest-report-file", "vest-report.log",
				"--vest-host", "127.0.0.1",
				"--vest-port", "37852"
			]

			var expected := VestCLI.Params.new()
			expected.run_file = "foo.gd"
			expected.run_glob = "*.test.gd"
			expected.report_format = "tap"
			expected.report_file = "vest-report.log"
			expected.host = "127.0.0.1"
			expected.port = 37852

			# When
			var actual := VestCLI.Params.parse(args)

			# Then
			expect_equal(actual.to_args(), expected.to_args())
		)
	)
