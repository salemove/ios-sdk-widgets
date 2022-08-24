fastlane documentation
----

# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```sh
xcode-select --install
```

For _fastlane_ installation instructions, see [Installing _fastlane_](https://docs.fastlane.tools/#installing-fastlane)

# Available Actions

## iOS

### ios increment_project_version

```sh
[bundle exec] fastlane ios increment_project_version
```

Increments versions in Xcode projects and Podspec file according to given type.

Usage:
fastlane increment_project_version type:major - increments X.0.0
fastlane increment_project_version type:minor - increments 0.X.0
fastlane increment_project_version type:patch - increments 0.0.X


### ios increment_static_version

```sh
[bundle exec] fastlane ios increment_static_version
```



### ios create_pull_request

```sh
[bundle exec] fastlane ios create_pull_request
```

Creates a pull request in the repository with whatever changes have been made. Used in tandem with Bitrise to update dependencies.

----

This README.md is auto-generated and will be re-generated every time [_fastlane_](https://fastlane.tools) is run.

More information about _fastlane_ can be found on [fastlane.tools](https://fastlane.tools).

The documentation of _fastlane_ can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
