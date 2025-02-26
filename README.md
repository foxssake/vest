![vest logo](./icon.png)

# vest

[![License](https://img.shields.io/github/license/foxssake/vest)](https://github.com/foxssake/vest/blob/main/LICENSE)
[![GitHub Release](https://img.shields.io/github/v/release/foxssake/vest)](https://github.com/foxssake/vest/releases)
[![Documentation](https://img.shields.io/badge/Docs-github.io-blue)](https://foxssake.github.io/vest/)
[![Discord](https://img.shields.io/discord/1253434107656933447?logo=discord&label=Discord)](https://discord.gg/xWGh4GskG5)
[![ko-fi](https://img.shields.io/badge/Support%20on-ko--fi-ff5e5b?logo=ko-fi)](https://ko-fi.com/T6T8WZD0W)

A unit testing library for Godot.

## Features

* 🆎 Define tests with test methods or programmatically with `define()`
* 📝 Parameterized tests to conveniently define multiple tests
* 🎭 Mock classes dynamically, for simpler unit testing
* ⚡ Run benchmarks, to find the best performing implementations
* 🗒️ Generate reports in [TAP] format, to integrate with other test harnesses
* ▶️ In-editor UI for convenient testing
* 🤖 Support for running in CI

## Overview

A testing addon for Godot, *vest* aims to bring all the features of a
full-fledged testing framework, while staying as lightweight and nonintrusive
as possible.

To this end, all tests are ran in the background, so developer flow is not
broken.

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

## Install

<!-- TODO: Update after release -->
* [Godot AssetLibrary](https://godotengine.org/asset-library/asset?filter=vest&category=&godot_version=&cost=&sort=updated)
* [GitHub release](https://github.com/foxssake/vest/releases)
* [Source](https://github.com/foxssake/vest/archive/refs/heads/main.zip)

## Usage

Extensive documentation can be found at the [vest site]. A good starting point
is the [Getting started] guide.

*Examples* are included in the [`examples/`] folder and in the documentation.

## Compatibility

Godot v4.1.4 and up

## License

*vest* is licensed under the [MIT License](LICENSE).

## Issues

In case of any issues, comments, or questions, please feel free to [open an issue]!

## Funding

If you've found *vest* useful, feel free to fund us on ko-fi:

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/T6T8WZD0W)

Donations are always appreciated and taken as gratitude for the work that has
already been done.


[TAP]: https://testanything.org/
[vest site]: https://foxssake.github.io/vest/latest/
[Getting started]: https://foxssake.github.io/vest/latest/getting-started/installing-vest/
[`examples/`]: https://github.com/foxssake/vest/tree/main/examples
[open an issue]: https://github.com/foxssake/vest/issues
