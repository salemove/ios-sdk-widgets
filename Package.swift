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
            url: "https://github.com/salemove/ios-bundle/releases/download/1.5.8/GliaCoreSDK.xcframework.zip",
            checksum: "ea56acef24af7016e35d58a03e07630d57f7950cabbbfee2f03059a9e6f7aec7"
        ),
        .binaryTarget(
            name: "GliaWidgetsSDKXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/2.8.3/GliaWidgetsXcf.xcframework.zip",
            checksum: "ec5c5419b91a04f433d5ebbda11e0cf145f37037fd3b2038adb07ed329f5a67f"
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
