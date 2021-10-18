
[order]: # (2)
# Getting Started

## Credentials
Before moving on to the actual integration make sure you have the following credentials from Glia:
* **App token**
* **Site ID**

You will also need to provide the **Visitor Context**. Visitor context specifies a content that can be shown to an Operator during an Engagement on the place of CoBrowsing section in Operator App. The only supported type for now is `.page`, which accepts a URL of a web page.

## Glia Hub Setup
Make sure you have the following information from the Glia Hub:
* The **region** ("environment") in which your app will be located (Europe or USA).
* The SDK will require using queues, where one or more operators can engage with customers. You will require a **Queue ID** in order for the app to understand which queue is should use.

## Integration

### Adding GliaWidgets iOS SDK to the Project

#### Swift Package Manager (SPM)
To integrate the GliaWidgets iOS SDK into your project via [Swift Package Manager](https://swift.org/package-manager/):
1. In Xcode, go to File > Swift Packages > Add Package Dependency...
2. Select your project in the opened menu.
3. Enter GliaWidgets repository URL into the search field:
`https://github.com/salemove/ios-sdk-widgets`

#### CocoaPods
To integrate the GliaWidgets iOS SDK into your project via [CocoaPods](https://cocoapods.org/) modify your `Podfile`:
```
source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/salemove/glia-ios-podspecs.git'

user_frameworks!

target 'YOUR_TARGET_NAME' do
    pod 'GliaWidgets', git: 'https://github.com/salemove/ios-sdk-widgets', tag: 'SDK_VERSION'
end

```

------------


### Application

#### Info.plist
Add the following privacy descriptions to your app's `Info.plist`:
- Privacy - Microphone Usage Description
- Privacy - Camera Usage Description
- Privacy - Photo Library Additions Usage Description

#### Importing
Import `GliaWidgets` and `SalemoveSDK`:
```swift
import GliaWidgets
import SalemoveSDK
```

#### Configuring and Customizing Glia
Firstly you must configure the Glia class.
The API token, app token, site ID and region will need to be added into your app:
```swift
let configuration = Configuration(
    appToken: "appToken",
    apiToken: "apiToken",
    environment: .europe,
    site: "site"
)
```

Now, create visitor context:
```swift
let visitorContext = VisitorContext(
    type: .page,
    url: "https://www.yoursite.com"
)
```

To listen Glia's events, use `onEvent`:
```swift
Glia.sharedInstance.onEvent = { event in
    switch event {
    case .started:
        break
    case .engagementChanged(let kind):
        break
    case .ended:
        break
    case .minimized:
        break
    case .maximized:
        break
    }
}
```

The GliaWidgets offer an extensive amount of customization. It is described in more detail on a [Creating a Theme](creating-a-theme) page. If you wish to keep the default appearance, call an empty initializer of `Theme`:
```swift
let theme = Theme()
```

#### Starting Glia
Finally, you can start the engagement:
```swift
do {
    try Glia.sharedInstance.start(
        .chat,
        configuration: configuration,
        queueID: "queueID",
        visitorContext: visitorContext,
        theme: theme
    )
} catch {
    // Handle the configuration error
}
```

You should now see the chat, which will automatically try to connect to the Glia Hub, where an operator can accept an incoming engagement request from you.
