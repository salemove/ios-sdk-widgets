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
            url: "https://github.com/salemove/ios-bundle/releases/download/2.6.12/GliaCoreSDK.xcframework.zip",
            checksum: "3091164c34ad87357c5d97d355c7015d038f28974175ae1821b55c84383f3cc3"
        ),
        .binaryTarget(
            name: "GliaWidgetsSDKXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/3.5.7/GliaWidgetsXcf.xcframework.zip",
            checksum: "da221cf954c5cba69d7e1eefeffac296159f2ca54b347023c8bf8fbf32a08370"
        ),
        .binaryTarget(
            name: "GliaOpenTelemetry",
            url: "https://github.com/salemove/ios-telemetry-bundle/releases/download/1.0.8/GliaOpenTelemetry.xcframework.zip",
            checksum: "9dd9e68d8312c601a69e73f46adf0132226168baa0e3f21415af47835c4d139d"
        ),
        .binaryTarget(
            name: "PhoenixChannelsClient",
            url: "https://github.com/salemove/phoenix-channels-kmm-bundle/releases/download/1.1.3/PhoenixChannelsClient.xcframework.zip",
            checksum: "ed1396ab1c96d6371b95f45b9c39e33fdcc44dae7180cc58e8cbadcaafac5c03"
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
