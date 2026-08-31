// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "GliaWidgets",
    defaultLocalization: .init(stringLiteral: "en"),
    platforms: [
        .iOS("15.1")
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
            url: "https://github.com/salemove/ios-bundle/releases/download/2.1.5/GliaCoreDependency.xcframework.zip",
            checksum: "e1167125f79667a360aa61dffefcb2cbfae56a85cc7ef0571bb033129186d1ce"
        ),
        .binaryTarget(
            name: "TwilioVoice",
            url: "https://github.com/salemove/ios-bundle/releases/download/0.33.0/TwilioVoice.xcframework.zip",
            checksum: "34288e0876a8840fa51d3813046cf1f40a5939079bea23ace5afe6e752f12f9e"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/stasel/WebRTC/releases/download/149.0.0/WebRTC-M149.xcframework.zip",
            checksum: "79c5a3e49a68de30a99baabaf5b4c0067dd7a0b66fdd4b8afb8ec337e746abba"
        ),
        .binaryTarget(
            name: "GliaCoreSDK",
            url: "https://github.com/salemove/ios-bundle/releases/download/2.6.14/GliaCoreSDK.xcframework.zip",
            checksum: "d8abd84935263511fe55f74f4f6e1b52e30195a1a60e47ec418da2fcb96b58bc"
        ),
        .binaryTarget(
            name: "GliaWidgetsSDKXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/3.5.8/GliaWidgetsXcf.xcframework.zip",
            checksum: "cf5161fba256161714534c1786794293338dc1327e2a4a67c1e31cd69b3dbf7b"
        ),
        .binaryTarget(
            name: "GliaOpenTelemetry",
            url: "https://github.com/salemove/ios-telemetry-bundle/releases/download/1.0.8/GliaOpenTelemetry.xcframework.zip",
            checksum: "9dd9e68d8312c601a69e73f46adf0132226168baa0e3f21415af47835c4d139d"
        ),
        .binaryTarget(
            name: "PhoenixChannelsClient",
            url: "https://github.com/salemove/phoenix-channels-kmm-bundle/releases/download/1.2.0/PhoenixChannelsClient.xcframework.zip",
            checksum: "5f9ba724c41196b6d200786dbd2c5cd9c275dcea99cbfe76a169eb9bb2c66bc2"
        ),
        .target(
            name: "GliaWidgets",
            dependencies: [
                .target(name: "GliaCoreDependency"),
                .target(name: "TwilioVoice"),
                .target(name: "WebRTC"),
                .target(name: "GliaOpenTelemetry"),
                .target(name: "PhoenixChannelsClient"),
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
                "GliaWidgetsSDKXcf",
                "PhoenixChannelsClient",
                "GliaOpenTelemetry"
            ],
            path: "Sources/GliaWidgetsSDK-xcframework"
        )
    ]
)
