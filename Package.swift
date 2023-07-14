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
            url: "https://github.com/salemove/ios-bundle/releases/download/1.0.4/GliaCoreSDK.xcframework.zip",
            checksum: "9e862431487ea8e9d0c56f6ae074824c09ccdbd86a1517d55734a56bcee13531"
        ),
        .binaryTarget(
            name: "GliaWidgetsXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/2.0.1/GliaWidgetsXcf.xcframework.zip",
            checksum: "26f6e0bc6e32f4223f635d8de8aa4877338aed7a323f2127a05980f347ac1f9a"
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
