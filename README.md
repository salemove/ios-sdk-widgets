# GliaWidgets iOS SDK

GliaWidgets SDK is a simple and customisable framework built on top of [GliaSDK](https://github.com/salemove/ios-bundle). It provides all the necessary UI components to quickly integrate GliaSDK into your project.

## Author

Glia Technologies

## Requirements

- iOS 12+
- [Xcode 12+](https://developer.apple.com/xcode/)
- Swift 5.3
- [Git LFS](https://git-lfs.github.com/)
- [CocoaPods](https://cocoapods.org/)

To build the Example application, follow the instructions below:

```sh
git clone --depth 1 git@github.com:salemove/ios-sdk-widgets.git
cd ios-sdk-widgets
make clone-snapshots
make integrate-githooks
pod install
xed GliaWidgets.xcworkspace
```

## Cocoapods

To integrate `GliaWidgets` into your project via [CocoaPods](https://cocoapods.org/), modify your `Podfile` as follows:

```
# Podfile

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/salemove/glia-ios-podspecs.git'

user_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'GliaWidgets'
end
```

## Swift Package Manager

To integrate `GliaWidgets` into your project via [Swift Package Manager](https://www.swift.org/package-manager/), add the following dependency: `https://github.com/salemove/ios-sdk-widgets`

## Communication

If you have any questions regarding our developer documentation, please submit a ticket to the [Glia Service Desk](https://salemove.atlassian.net/servicedesk/customer/portal/1). If you do not have access to it, contact your Customer Success Manager for access.

## License

Glia SDK (Salemove SDK) is available under the MIT license. See the [LICENSE file](LICENSE) for more information.
