# Running from UI

*Vest*'s UI lives in the editor's bottom panel.

![vest UI](../assets/vest-ui.png)

## Elements

While each element has its tooltip or description, here's an overview:

![Run](../assets/ui/run.svg) Run tests
:   Run all test scripts matching the *Test glob*.

![Debug](../assets/ui/debug.svg) Debug tests
:   Run all test scripts matching the *Test glob*, in debug mode.
    
    Useful when something doesn't behave as expected and needs debugging.

![Clear](../assets/ui/clear.svg) Clear results
:   Clear the test report, emptying the panel.

![Run on save](../assets/ui/run-save.svg) Run on save
:   Toggles *Run on save* - when enabled, tests are re-run each time a script
    is modified and saved.

    Useful for getting quick feedback while implementing tests.

![Refresh mixins](../assets/ui/refresh.svg) Refresh mixins
:   Vest's `VestTest` class is generated from multiple *mixin* classes. In case
    any of these change, use the *Refresh mixins* button to update the generated
    classes.

    Usually only necessary during addon development.

## Run vs. Debug

In order to be as unintrusive as possible, *vest* runs your tests in the
background, in headless mode. This means spawning a process *completely
independent* of the Godot editor, without connecting to the debugger.

Running tests independently means that the editor cannot debug the tests while
running, or receive any `print()`s.

If you want to debug your tests, use the ![Debug](../assets/ui/debug.svg)
*debug* button.
