# Printing custom messages

In case you want to include custom data in the test report - either as
temporary debug messages or custom report data -, *vest* allows you to emit
messages from your tests.

=== "define()"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Print test"

    func suite():
      test("Custom message", func():
        var date := Time.get_date_dict_from_system()
        var date_string := "%d-%02d-%02d" % [date["year"], date["month"], date["day"]]
        Vest.message("Tests ran on %s" % [date_string])
        ok()
      )
    ```
=== "methods"
    ```gdscript
    extends VestTest

    func get_suite_name() -> String:
      return "Print test"

    func test_custom_message():
      var date := Time.get_date_dict_from_system()
      var date_string := "%d-%02d-%02d" % [date["year"], date["month"], date["day"]]
      Vest.message("Tests ran on %s" % [date_string])
      ok()
    ```

Call `Vest.message()`, and its parameter will be stored as a test message.
These messages are then included in the test reports.

Each message is associated with the currently running ( or, if not available,
about to be ran ) test case.
