# Writing tests

*Vest* defines tests as a set of *suites*. Each *suite* may contain test
*cases*, *benchmark*, and even nested *suites*.

For example, the suite could cover the class ( unit )  being tested, with each
method receiving its own suite of requirements, each being covered by a test
case:

```
Set
├── add()
│   ├── should add unknown item
│   └── should do nothing on known item
├── has()
│   ├── should return false on empty set
│   ├── should return false on unknown item
│   └── should return true on known item
└── erase()
    ├── should erase known item
    └── should do nothing on unknown item
```

In this example, the `Set` suite has 3 subsuites, each with their own test cases.

## Defining suites

*Vest* considers classes extending the `VestTest` base class as tests. Each
example in the documentation will present both styles:

=== "define()"

    ```gdscript
    extends VestTest

    func suite():
      define("Test suite", func():
        test("Should do A", func(): pass)
        test("Should do B", func(): pass)
        test("Should do C", func(): pass)

        define("Nested suite", func():
          test("Should do D", func(): pass)
        )
      )
    ```

=== "methods"

    ```gdscript
    extends VestTest

    func test_should_do_a():
      pass

    func test_should_do_b():
      pass

    func test_should_do_c():
      pass
    ```

### With define

Methods whose names start with `suite` are considered suite definitions and are
expected to use `define()`. The method name can be anything ( even simply
`suite()` ), and will be called once, before running the test class.

Inside `define()`, use `test()` to define individual test cases. For nested
suites, use `define()` inside itself. There's no limit on the amount of
nesting.

As shown in the examples, `test()` takes a test name, and a function. This
function contains the actual test case implementation.

The method name has no bearing on the suites or cases defined.

### With methods

Methods whose names start with `test` are considered test case definitions. The
test case name is derived from the method name, e.g.
`test_should_return_false_on_null()` becomes `Should Return False On Null`.

The function body contains the test case implementation.

### Suite name

Each suite and test case defined inside the class is part of the suite that
belongs to the test class. There's different ways to set the suite name. In
order of precedence:

1. Implement `get_suite_name()`:
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Example Suite"
    ```
1. Use `class_name`:
    ```gdscript
    extends VestTest
    class_name ExampleSuite
    ```
1. If none of the above are present, *vest* will use the script's path, e.g.
   `res://tests/example_test.gd`

To find out how to set test outcomes, continue reading about assertions and
test results!
