# Running on CI

By levaraging it's [CLI support], *vest* can be used on CI as well.

## General use

Usually a pipeline for running *vest* tests consists of the following steps:

1. Grab the Godot project
1. Setup Godot
1. Run *vest* CLI
1. Check results

While most steps are platform-specific, running the CLI and inspecting results
is not.

Running the CLI is covered in the [CLI support] page.

To check results, export the test results in *[TAP]* format, and check if the
report contains a line starting with *"not ok"*. If so, there were test
failures, otherwise the tests have passed.

!!!note
    A much more sensible approach would be to check exit codes. While *vest*
    *does* set the exit code when ran from the CLI, this seems to be not always
    respected by Godot.

Usually on CI the project is freshly copied, meaning the test run would be the
first time Godot opens and imports the project. For earlier versions ( 4.1, 4.2
), a separate *import* step might be needed for Godot to properly parse the
project. After the import is done, the tests may be ran.

Let's see all of that in an example script:

```sh
echo "Import project"
godot --headless --import .

echo "Run vest"
godot --headless -s "addons/vest/cli/vest-cli.gd" \
      --vest-report-format tap --vest-report-file "vest.log" \
      --vest-glob "res://test/*.test.gd"

if grep "not ok" "vest.log"; then
  echo "There are failing test(s)!"
  exit 1
else
  print "Success!"
fi
```

The script first imports the project with Godot, then runs the tests. After the
run is complete, it checks the test report for failures.

## Using with Github Actions

As with many Github Actions workflows, the starting step is to checkout the
repository.

Godot itself can be setup with [Chickensoft]'s excellent [Setup Godot] action.

For a complete example, feel free to refer to *vest*'s own [GHA setup], or the
following minimal example:

```yaml
name: CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:

jobs:
  test:
    name: Run tests
    runs-on: ubuntu-latest
    steps:
      - name: Checkout 
        uses: actions/checkout@v2
      - name: Setup Godot
        uses: chickensoft-games/setup-godot@v1
        with:
          version: 4.2.2
          use-dotnet: false
          include-templates: false
      - name: Run tests
        run: |
          godot --headless --import .
          godot --headless -s "addons/vest/cli/vest-cli.gd" \
                --vest-report-format tap --vest-report-file "vest.log" \
                --vest-glob "res://test/*.test.gd"
          if grep "not ok" "vest.log"; then
            exit 1
          fi
```


[CLI support]: ./running-from-cli.md
[TAP]: https://testanything.org/
[Chickensoft]: https://chickensoft.games/
[Setup Godot]: https://github.com/chickensoft-games/setup-godot
[GHA setup]: https://github.com/foxssake/vest/blob/main/.github/workflows/ci.yml
