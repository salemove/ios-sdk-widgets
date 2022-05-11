# GliaWidgets iOS SDK

GliaWidgets SDK, is a simple and customisable framework that is built on top of [GliaSDK](https://github.com/salemove/ios-bundle). It provides all necessary UI components for fast integration GliaSDK into a project.

## Author

Glia Technologies


## Requirements
 - iOS 12+
 - [Xcode 12+](https://developer.apple.com/xcode/)
 - Swift 5.3
 - [Git LFS](https://git-lfs.github.com/)
 - [CocoaPods](https://cocoapods.org/)

To build the Example application please follow this instruction:
```sh
git clone --depth 1 git@github.com:salemove/ios-sdk-widgets.git
cd ios-sdk-widgets
make clone-snapshots
pod install
xed GliaWidgets.xcworkspace
```


## Cocoapods

For integration, the `GliaWidgets` into your project via [CocoaPods](https://cocoapods.org/) modify your `Podfile`
```
# Podfile

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/salemove/glia-ios-podspecs.git'

user_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'GliaWidgets', git: 'https://github.com/salemove/ios-sdk-widgets', tag: 'SDK_VERSION'
end

```

## Communication

If you have any questions regarding our developer documentation please file a ticket in [Glia Jira Service Desk](https://salemove.atlassian.net/servicedesk/customer/portal/1). If you do not have access to that, then please contact your Success Manager for access.


## License

Glia SDK (Salemove SDK) is available under the MIT license. See the [LICENSE file](LICENSE) for more info.
