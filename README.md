# GliaWidgets iOS SDK

GliaWidgets SDK is a simple and customisable framework built on top of [GliaSDK](https://github.com/salemove/ios-bundle). It provides all the necessary UI components to quickly integrate GliaSDK into your project.

## Author

Glia Technologies

## Requirements

- iOS 14+
- [Xcode 15.1+](https://developer.apple.com/xcode/)
- Swift 5.3
- [Git LFS](https://git-lfs.github.com/)

To build the Example application, follow the instructions below:

```sh
git clone --depth 1 git@github.com:salemove/ios-sdk-widgets.git
cd ios-sdk-widgets
make clone-snapshots
make integrate-githooks
xed GliaWidgets.xcworkspace
```

Xcode resolves the dependencies through Swift Package Manager when the workspace opens.

### Building against a local GliaCoreSDK

By default the project links the released GliaCoreSDK xcframework. To build it from a local
[ios-sdk](https://github.com/salemove/ios-sdk) checkout instead:

```sh
scripts/local-core enable ../ios-sdk   # build GliaCoreSDK from sources
scripts/local-core disable             # back to the released xcframework
scripts/local-core status
```

After switching, resolve packages again (File > Packages > Resolve Package Versions) and clean the build folder.

## Swift Package Manager

To integrate `GliaWidgets` into your project via [Swift Package Manager](https://www.swift.org/package-manager/), add the following dependency: `https://github.com/salemove/ios-sdk-widgets`

## Communication

If you have any questions regarding our developer documentation, please submit a ticket to the [Glia Service Desk](https://salemove.atlassian.net/servicedesk/customer/portal/1). If you do not have access to it, contact your Customer Success Manager for access.

## License

Glia SDK (Salemove SDK) is available under the MIT license. See the [LICENSE file](LICENSE) for more information.
