// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GliaWidgets",
    defaultLocalization: .init(stringLiteral: "en"),
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "GliaWidgets",
            targets: ["GliaWidgets"]
        ),
        .library(
            name: "GliaWidgetsXcf",
            targets: ["GliaWidgetsXcf"]
        )
    ],
    targets: [
        .binaryTarget(
            name: "GliaCoreDependency",
            url: "https://github.com/salemove/ios-bundle/releases/download/1.3.5/GliaCoreDependency.xcframework.zip",
            checksum: "a7ca12542bc8470af16632311e96a1925f102e0ee6d36f5c86e422aebe655af1"
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
            url: "https://github.com/salemove/ios-bundle/releases/download/2.0.16/GliaCoreSDK.xcframework.zip",
            checksum: "782dbb85c5ef32d8477b2677e003ff5e804d533e3b36832d73373a274de493f9"
        ),
        .binaryTarget(
            name: "GliaWidgetsSDKXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/3.0.1/GliaWidgetsXcf.xcframework.zip",
            checksum: "b9df1d22a5e835e241c8825ea175a8f41d0f6a044a0f05fbc64de1dbcf71f8f5"
        ),
        .target(
            name: "GliaWidgets",
            dependencies: [
                .target(name: "GliaCoreDependency"),
                .target(name: "TwilioVoice"),
                .target(name: "WebRTC"),
                .target(name: "GliaCoreSDK")
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
            name: "GliaWidgetsXcf",
            dependencies: [
                "GliaCoreSDK",
                "GliaCoreDependency",
                "TwilioVoice",
                "WebRTC",
                "GliaWidgetsSDKXcf"
            ],
            path: "Sources/GliaWidgetsSDK-xcframework"
        )
    ]
)
