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
            url: "https://github.com/salemove/ios-bundle/releases/download/1.5.0/GliaCoreSDK.xcframework.zip",
            checksum: "f9d7d528e124169887a62bf713533395948e8e3ccf28e85ddf597f4a8b01beff"
        ),
        .binaryTarget(
            name: "GliaWidgetsSDKXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/2.6.0/GliaWidgetsXcf.xcframework.zip",
            checksum: "4576caf383a972942c28dfb51181dffb06988fe11e85d18acbc78138a203ff15"
        ),
        .target(
            name: "GliaWidgets",
            dependencies: [
                .target(name: "GliaCoreDependency"),
                .target(name: "TwilioVoice"),
                .target(name: "WebRTC"),
                .target(name: "GliaCoreSDK"),
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
