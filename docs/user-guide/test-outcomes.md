# Test outcomes

Test cases can have the following outcomes:

Pass
: All requirements are fulfilled, the test subject works as expected.

Fail
: Some or all of the requirements are broken, the test subject doesn't work as
  expected.

Skip
: The test has skipped validating requirements. Often used for temporarily
  disabling tests.

TODO
: The test is yet to be implemented.

Void
: No assertions have been made. Usually happens with empty test methods, or if
  the test ran into an engine-level issue ( e.g. syntax- or runtime errors )

Test outcomes can be manually set using the corresponding method:

- `ok()`
- `fail()`
- `skip()`
- `todo()`

The recommended way is to use [assertions](./assertions.md).
