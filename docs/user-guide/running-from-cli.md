# Running from CLI

*Vest* can be ran without the Godot editor, by supporting CLI usage.

```sh
$ godot --headless -s addons/vest/cli/vest-cli.gd --vest-glob "res://tests/*.test.gd" --vest-report-format tap
Godot Engine v4.2.2.stable.official.15073afe3 - https://godotengine.org

TAP version 14
1..2
# Subtest: Equality
  1..6
  ok 1 - Arrays should be equal
  ok 2 - Arrays should differ
  ok 3 - Dictionaries should be equal
  ok 4 - Dictionaries should differ
  ok 5 - Should equal on custom method
  ok 6 - Should differ on custom method
ok 1 - Equality
# Subtest: Mocks
  1..7
  ok 1 - Should Return Default
  ok 2 - Should Return On Args
  ok 3 - Should Return Default On Wrong Args
  ok 4 - Should Answer Default
  ok 5 - Should Answer On Args
  ok 6 - Should Answer Default On Wrong Args
  ok 7 - Should Record Calls
ok 2 - Mocks
```

## Running vest

The script exposing *vest*'s CLI functionality is at
`addons/vest/cli/vest-cli.gd`. Run this script with [Godot's command line
support], optionally specifying *headless* mode:

```sh
godot --headless -s addonst/vest/cli/vest-cli.gd [...]
```

After the script, optional parameters can be specified for *vest*.

## Command line parameters

`--vest-file`
:   Specify the test script file to run. Mutually exclusive with `--vest-glob`.

`--vest-glob`
:   Specify the test glob to use for finding test scripts. Mutually exclusive with `--vest-file`.

`--vest-report-format`
:   Specify the report format. Currently only `tap` is supported. If not
    specified, no report will be written.

`--vest-report-file`
:   Specify the output file for saving the test report. The report will be
    printed to STDOUT if not specified.

`--vest-host`
:   *Internal only*. Specifies the host to connect to for sending test results.

`--vest-port`
:   *Internal only*. Specifies the port to use for sending test results.

[Godot's command line support]: https://docs.godotengine.org/en/latest/tutorials/editor/command_line_tutorial.html
