// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GliaWidgets",
    defaultLocalization: .init(stringLiteral: "en"),
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "GliaWidgets",
            targets: ["GliaWidgetsSDK"]
        ),
        .library(
            name: "GliaWidgets-xcframework",
            targets: ["GliaWidgetsSDK-xcframework"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios", from: "3.3.0"),
        .package(url: "https://github.com/PureLayout/PureLayout", from: "3.1.9")
    ],
    targets: [
        .binaryTarget(
            name: "GliaCoreDependency",
            url: "https://github.com/salemove/ios-bundle/releases/download/0.35.0/GliaCoreDependency.xcframework.zip",
            checksum: "8e1746da612dad8a130fd872b3058511121b7c6f29e3b0351ecbbffa96971489"
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
            name: "GliaCoreSDK",
            url: "https://github.com/salemove/ios-bundle/releases/download/1.0.2/GliaCoreSDK.xcframework.zip",
            checksum: "4d997e74bb975db723b7d93a26f2fb3611f735f809a825aa2e89e5226cc602d4"
        ),
        .binaryTarget(
            name: "PureLayoutXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/0.10.8/PureLayoutXcf.xcframework.zip",
            checksum: "93f00268ba710a0ee513be7cef94a385637bfb76c292942cc5f062a7b2f0037b"
        ),
        .binaryTarget(
            name: "LottieXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/0.10.8/LottieXcf.xcframework.zip",
            checksum: "9f2340bfb15f734ebd3a4e79d67ce3581822aa5ceec3a37a38ebaa505bf1a8a3"
        ),
        .binaryTarget(
            name: "GliaWidgetsXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/2.0.0/GliaWidgetsXcf.xcframework.zip",
            checksum: "1517a94933f0b485f5ad187a8fd3e55d0c0bacc86ad69847785ab6d49cb0c2d5"
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
                "GliaCoreSDK",
                "GliaCoreDependency",
                "TwilioVoice",
                "WebRTC",
                "GliaWidgets"
            ]
        ),
        .target(
            name: "GliaWidgetsSDK-xcframework",
            dependencies: [
                "GliaCoreSDK",
                "GliaWidgetsXcf",
                "GliaCoreDependency",
                "TwilioVoice",
                "WebRTC",
                "PureLayoutXcf",
                "LottieXcf"
            ]
        )
    ]
)
