
[order]: # (2)
# Getting Started

## Credentials
Before moving on to the actual integration make sure you have the following credentials from Glia:
* **API token**
* **App token**
* **Site ID**

You will also need to provide a **Context URL**, which will give the operator the information regarding the context of what URL you are accessing the engagement from (usually your application's main site ID, i.e. www.glia.com).

## Glia Hub Setup
Make sure you have the following information from the Glia Hub:
* The **region** in which your app will be located.
* The SDK will require using queues, where one or more operators can engage with customers. You will require a **Queue ID** in order for the app to understand in which queue you will be located.

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

#### Configuring and Starting Glia
Firstly you must configure the GliaWidgets class.
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

Finally, you can start the engagement:
```swift
do {
    try Glia.sharedInstance.start(
        .chat,
        configuration: configuration,
        queueID: "queueID",
        visitorContext: visitorContext
    )
} catch {
    // Handle the configuration error
}
```

You should now see the chat, which will automatically try to connect to the Glia Hub, where an operator can accept an incoming engagement request from you.
