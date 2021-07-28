// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "GliaWidgets",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "GliaWidgets",
            targets: ["GliaWidgetsSDK"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "TwilioVoice",
            url: "https://github.com/salemove/ios-bundle/releases/download/0.27.0/TwilioVoice.xcframework.zip",
            checksum: "039b38797721ed272abdb69780cd3239961786d94175b6846036dad4c4a5b636"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/salemove/ios-bundle/releases/download/0.27.0/WebRTC.xcframework.zip",
            checksum: "996f02aff0f0ade1a16f0d8798150e58a126934ebdfd20610421931bfa459859"
        ),
        .binaryTarget(
            name: "SalemoveSDK",
            url: "https://github.com/salemove/ios-bundle/releases/download/0.30.0/SalemoveSDK.xcframework.zip",
            checksum: "6d9beb6fa22f02ae1f20aa7d8259744becf83ff354e5ea7e01310ae30a390cfe"
        ),
        .binaryTarget(
            name: "GliaWidgets",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/0.5.0/GliaWidgets.xcframework.zip",
            checksum: "d7a63774d8d1595103015a3e56436fe8e48ff211bcbefdd7db206cfa48d88145"
        ),
        .binaryTarget(
            name: "PureLayout",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/0.1.0/PureLayout.xcframework.zip",
            checksum: "ba40b3770921a77ed8be07836ec8b89f6d93bab623f46b54d8c2a05b74a44ef0"
        ),
        .target(
            name: "GliaWidgetsSDK",
            dependencies: [
                "SalemoveSDK",
                "GliaWidgets",
                "TwilioVoice",
                "WebRTC",
                "PureLayout"
            ]
        )
    ]
)
