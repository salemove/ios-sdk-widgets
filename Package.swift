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
            url: "https://github.com/salemove/ios-bundle/releases/download/1.1.1/GliaCoreSDK.xcframework.zip",
            checksum: "7035aa742cc37ec7006331b1e3ac9ecc2916bce65d965df24cdd8c3f264bd3de"
        ),
        .binaryTarget(
            name: "GliaWidgetsXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/2.0.6/GliaWidgetsXcf.xcframework.zip",
            checksum: "27dd290835cc21e8191d16d128c8b4d19a7bda8f34029821626eefd91a7c448b"
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
                "WebRTC"
            ]
        )
    ]
)
