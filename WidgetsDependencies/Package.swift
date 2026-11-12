// swift-tools-version:5.9

import PackageDescription

// GliaCoreSDK and the binaries it links, for the targets in GliaWidgets.xcodeproj.
//
// The project references this as a local package and links its `GliaCore` product.
//
// The url and checksum pairs mirror the Package.swift of the ios-bundle release
// named in the GliaCoreSDK url, and have to move together with it. They are
// declared here rather than pulled in through the ios-bundle package because
// that repository keeps every released xcframework in its history, which makes
// it a 650 MB clone.
//
// To build GliaCoreSDK from a local ios-sdk checkout instead, run
// `scripts/local-core enable`. It writes an untracked manifest next to this one
// that SwiftPM prefers over this file.
let package = Package(
    name: "WidgetsDependencies",
    platforms: [
        .iOS("15.1")
    ],
    products: [
        .library(
            name: "GliaCore",
            targets: [
                "GliaCoreSDK",
                "GliaCoreDependency",
                "TwilioVoice",
                "WebRTC",
                "PhoenixChannelsClient",
                "GliaOpenTelemetry"
            ]
        )
    ],
    targets: [
        .binaryTarget(
            name: "GliaCoreSDK",
            url: "https://github.com/salemove/ios-bundle/releases/download/4.0.1/GliaCoreSDK.xcframework.zip",
            checksum: "970110dbe7674dee5e3e1e60ebd0ca3ba7aaeef19ce76af0e02ef4804872d7c8"
        ),
        .binaryTarget(
            name: "GliaCoreDependency",
            url: "https://github.com/salemove/ios-bundle/releases/download/2.1.5/GliaCoreDependency.xcframework.zip",
            checksum: "e1167125f79667a360aa61dffefcb2cbfae56a85cc7ef0571bb033129186d1ce"
        ),
        .binaryTarget(
            name: "TwilioVoice",
            url: "https://github.com/twilio/twilio-voice-ios/releases/download/6.8.0/TwilioVoice.xcframework.zip",
            checksum: "298ff9bae7eb434e911dd14a2d40c3582dc97133d3e3dbbe23f2088726301ddf"
        ),
        .binaryTarget(
            name: "WebRTC",
            url: "https://github.com/stasel/WebRTC/releases/download/149.0.0/WebRTC-M149.xcframework.zip",
            checksum: "79c5a3e49a68de30a99baabaf5b4c0067dd7a0b66fdd4b8afb8ec337e746abba"
        ),
        .binaryTarget(
            name: "PhoenixChannelsClient",
            url: "https://github.com/salemove/phoenix-channels-kmm-bundle/releases/download/1.3.2/PhoenixChannelsClient.xcframework.zip",
            checksum: "efe66666503af08fbcbd6020fe0c4c79fcb30bfac8f9fef0e03fa1b8a86e3f2d"
        ),
        .binaryTarget(
            name: "GliaOpenTelemetry",
            url: "https://github.com/salemove/ios-telemetry-bundle/releases/download/1.1.1/GliaOpenTelemetry.xcframework.zip",
            checksum: "89914f3366e686991f96454b5e0c970a31a1e84c58d62704bf3f94cb84349d48"
        )
    ]
)
