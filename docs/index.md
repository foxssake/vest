[![License](https://img.shields.io/github/license/foxssake/vest)](https://github.com/foxssake/vest/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/foxssake/vest)](https://github.com/foxssake/vest/releases)
[![Documentation](https://img.shields.io/badge/Docs-github.io-blue)](https://foxssake.github.io/vest/)
[![Discord](https://img.shields.io/discord/1253434107656933447?logo=discord&label=Discord)](https://discord.gg/xWGh4GskG5)
[![ko-fi](https://img.shields.io/badge/Support%20on-ko--fi-ff5e5b?logo=ko-fi)](https://ko-fi.com/T6T8WZD0W)

A unit testing library for [Godot].

## Features

* ✨ Define tests with test methods or programmatically with `define()`
* 📝 Parameterized tests to conveniently define multiple tests
* 🎭 Mock classes dynamically, for simpler unit testing
* ⚡ Run benchmarks, to find the best performing implementations
* 🗒️ Generate reports in [TAP] format, to integrate with other test harnesses
* 🔁 [Coroutines] for asynchronous cases
* ▶️ In-editor UI for convenient testing
* 🤖 Support for running in CI

## Overview

A testing addon for [Godot], *vest* aims to bring all the features of a
full-fledged testing framework, while staying as lightweight and nonintrusive
as possible.

Tests written with *vest* look as follows:

```gdscript
extends VestTest

# Specify name shown in reports
func get_suite_name() -> String:
  return "pow()"

# With define():
func suite():
  test("exp 0 should return 1", func():
    expect_equal(1, pow(128, 0))
  )
  test("exp 1 should return input", func():
    expect_equal(128, pow(128, 128))
  )

# With test methods:
func test_exp_0_should_return_1():
  expect_equal(1, pow(128, 0))

func test_exp_1_should_return_inpt():
  expect_equal(128, pow(128, 128))
```


## Compatibility

Godot v4.1.4 and up


[Godot]: https://godotengine.org/
[TAP]: https://testanything.org/
[Coroutines]: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_basics.html#awaiting-signals-or-coroutines
