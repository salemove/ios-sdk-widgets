// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "GliaWidgets",
    defaultLocalization: .init(stringLiteral: "en"),
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
            name: "ReactiveSwift",
            url: "https://github.com/salemove/glia-ios-podspecs/releases/download/1.0/ReactiveSwift.xcframework.zip",
            checksum: "f1322d3e07b01a4f2b1329b7ed43494259fba740c666231422b373ec50dc1e7d"
        ),
        .binaryTarget(
            name: "SocketIO",
            url: "https://github.com/salemove/glia-ios-podspecs/releases/download/1.0/SocketIO.xcframework.zip",
            checksum: "119a21a9d7d0b9a20b0705e5c639cb57cc1d93ee08874a89dd53b8ca23905ad6"
        ),
        .binaryTarget(
            name: "Starscream",
            url: "https://github.com/salemove/glia-ios-podspecs/releases/download/1.0/Starscream.xcframework.zip",
            checksum: "bd400c148711147d78c9c549e05f0ca7b4afdd486f387496080fb5aed8580260"
        ),
        .binaryTarget(
            name: "SwiftPhoenixClient",
            url: "https://github.com/salemove/glia-ios-podspecs/releases/download/1.0/SwiftPhoenixClient.xcframework.zip",
            checksum: "0efab6ac7d72a8242af69095d72d51a12f33438447a7e41f9edf84e15a08c7bb"
        ),
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
            url: "https://github.com/salemove/ios-bundle/releases/download/0.32.0/SalemoveSDK.xcframework.zip",
            checksum: "2f548182f0a4db0cc6ce96e3617ddcdfc5b2463fbab45c94983753f5ad33f841"
        ),
        .target(
            name: "GliaWidgets",
            path: "GliaWidgets",
            exclude: [
                "Cartfile.resolved",
                "Cartfile",
                "Info.plist"
            ],
            resources: [
                .process("Resources")
            ]
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
                "ReactiveSwift",
                "SocketIO",
                "SwiftPhoenixClient",
                "Starscream",
                "TwilioVoice",
                "WebRTC",

                "GliaWidgets",
                "PureLayout",
                "Lottie"
            ]
        )
    ]
)
