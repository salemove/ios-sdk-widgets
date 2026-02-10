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
            url: "https://github.com/salemove/ios-bundle/releases/download/0.33.0/WebRTC.xcframework.zip",
            checksum: "f76e410f608d96989ba0312e099697703a37b4414f8f46bb9e30c3d9b4291a52"
        ),
        .binaryTarget(
            name: "GliaCoreSDK",
            url: "https://github.com/salemove/ios-bundle/releases/download/2.6.2/GliaCoreSDK.xcframework.zip",
            checksum: "c7dff11f67fbccfe6a6b22d1ada08fb1ac64dd775d489bf8bf6c938804eebe63"
        ),
        .binaryTarget(
            name: "GliaWidgetsSDKXcf",
            url: "https://github.com/salemove/ios-sdk-widgets/releases/download/3.4.0/GliaWidgetsXcf.xcframework.zip",
            checksum: "9741bc7cc3f196d55eaa132371591e4b641db1629e772a3d72398eb7dc31345b"
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
