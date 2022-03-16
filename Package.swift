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
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios", from: "3.3.0"),
        .package(url: "https://github.com/PureLayout/PureLayout", from: "3.1.9")
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
            url: "https://github.com/salemove/ios-bundle/releases/download/0.33.0/TwilioVoice.xcframework.zip",
            checksum: "34288e0876a8840fa51d3813046cf1f40a5939079bea23ace5afe6e752f12f9e"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/salemove/ios-bundle/releases/download/0.33.0/WebRTC.xcframework.zip",
            checksum: "f76e410f608d96989ba0312e099697703a37b4414f8f46bb9e30c3d9b4291a52"
        ),
        .binaryTarget(
            name: "SalemoveSDK",
            url: "https://github.com/salemove/ios-bundle/releases/download/0.33.1/SalemoveSDK.xcframework.zip",
            checksum: "6f911b712accb0d91c927d5c2c4fb60a4fb26255c71a7ad51da45e4744122158"
        ),
        .target(
            name: "GliaWidgets",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "PureLayout", package: "PureLayout")
            ],
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
                "GliaWidgets"
            ]
        )
    ]
)
