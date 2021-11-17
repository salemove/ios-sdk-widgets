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
            url: "https://github.com/salemove/ios-bundle/releases/download/0.31.0/SalemoveSDK.xcframework.zip",
            checksum: "d02bf87ffca0a42a8c7f4243912bd8bb6b9c12759c8081e6e550895363acb3a9"
        ),
        .binaryTarget(
            name: "GliaWidgets",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/0.5.8/GliaWidgets.xcframework.zip",
            checksum: "3d33ac089a04f4a174860c586e94d3193e527cb88669bdfb89e9e086bedb507d"
        ),
        .binaryTarget(
            name: "PureLayout",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/0.1.0/PureLayout.xcframework.zip",
            checksum: "ba40b3770921a77ed8be07836ec8b89f6d93bab623f46b54d8c2a05b74a44ef0"
        ),
        .binaryTarget(
            name: "Lottie",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/0.5.6/Lottie.xcframework.zip",
            checksum: "59dcfe3e2f8fd4754e09c6ede76c05331324f0d78aeace90d2d35b158d619093"
        ),
        .target(
            name: "GliaWidgetsSDK",
            dependencies: [
                "SalemoveSDK",
                "GliaWidgets",
                "TwilioVoice",
                "WebRTC",
                "PureLayout",
                "Lottie"
            ]
        )
    ]
)
