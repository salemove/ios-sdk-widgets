// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GliaWidgets",
    defaultLocalization: .init(stringLiteral: "en"),
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "GliaWidgets",
            targets: ["GliaWidgetsSDK"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/airbnb/lottie-ios", from: "3.3.0"),
        .package(url: "https://github.com/PureLayout/PureLayout", from: "3.1.9")
    ],
    targets: [
        .binaryTarget(
            name: "ReactiveSwift",
            url: "https://github.com/salemove/glia-ios-podspecs/releases/download/1.0/ReactiveSwift.xcframework.zip",
            checksum: "f1322d3e07b01a4f2b1329b7ed43494259fba740c666231422b373ec50dc1e7d"
        ),
        .binaryTarget(
            name: "GliaCoreDependency",
            url: "https://github.com/salemove/glia-ios-podspecs/releases/download/1.0/GliaCoreDependency.xcframework.zip",
            checksum: "bc770dbc55b188884c128a77f4c8fddf6c872d24eeff274e410bd3206d125e77"
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
            name: "SalemoveSDK",
            url: "https://github.com/salemove/ios-bundle/releases/download/0.33.4/SalemoveSDK.xcframework.zip",
            checksum: "894c7b4cb4e19b6e27efbbb1b16cd94b0e205ef3f554cbb2f776f7591ccfa10e"
        ),
        .target(
            name: "GliaWidgets",
            dependencies: [
                .product(name: "Lottie", package: "lottie-ios"),
                .product(name: "PureLayout", package: "PureLayout")
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
            name: "GliaWidgetsSDK",
            dependencies: [
                "SalemoveSDK",
                "ReactiveSwift",
                "GliaCoreDependency",
                "TwilioVoice",
                "WebRTC",
                "GliaWidgets"
            ]
        )
    ]
)
