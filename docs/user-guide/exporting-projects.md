# Exporting projects

The functionalities that *vest* provides are useful during development, but are
not needed during gameplay. Thus, it makes sense to exclude *vest* when
exporting your Godot project. Doing so saves file size, bandwidth, and may
slightly improve startup time.

To do so, open *Project* > *Export...*, and then navigate to the *Resources*
tab on your selected export preset.

![Export settings](../assets/export-settings.png)

The above example demonstrates one way to exclude *vest* from your final build.
In general, it is good practice to only export resources needed by the game.
The example also excludes script templates and test suites from the build.

## Avoiding errors

In general, *always* make sure to test your build before submitting or
uploading it to your chosen platform.

To avoid issues stemming from unresolved references, make sure to only
reference `Vest`, and other classes provided by *vest*, in your tests. Doing so
ensures that excluding *vest* and your tests from the build won't result in any
issues.
