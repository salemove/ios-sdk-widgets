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
            url: "https://github.com/salemove/ios-bundle/releases/download/1.0.6/GliaCoreSDK.xcframework.zip",
            checksum: "61747e286e5327659f765991f6f927608caad848bea4f2a0089bf6064686b85f"
        ),
        .binaryTarget(
            name: "GliaWidgetsXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/2.0.4/GliaWidgetsXcf.xcframework.zip",
            checksum: "701a98b8684a1b73a2adc65bcebac0c04bd2af1ecbdfcdabe1495847daee1f56"
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
