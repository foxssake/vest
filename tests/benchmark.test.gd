extends VestTest

var buffer := ""

func before_each():
	buffer = ""

func benchmark_iterations(iterations = 1024):
	buffer += "line"

func benchmark_time(timeout = 0.1):
	buffer += "line"
