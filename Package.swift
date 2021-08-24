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
            url: "https://github.com/salemove/ios-bundle/releases/download/0.30.1/SalemoveSDK.xcframework.zip",
            checksum: "e96e032b35451963cc5c826e7d3e44e44ab1029ea75f961858eeafe60e856c37"
        ),
        .binaryTarget(
            name: "GliaWidgets",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/0.5.1/GliaWidgets.xcframework.zip",
            checksum: "7c2702cf811c38cfacfe0297aee0f68804c9d8dd925e30b534d5b1224a00b215"
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
