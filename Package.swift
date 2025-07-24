// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "GliaWidgets",
    defaultLocalization: .init(stringLiteral: "en"),
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "GliaWidgets",
            targets: ["GliaWidgets"]
        )
    ],
    dependencies: [
        .package(path: "../ios-sdk/GliaCoreSDK"),
    ],
    targets: [
        .target(
            name: "GliaWidgets",
            dependencies: [
                .product(name: "GliaCoreSDK", package: "GliaCoreSDK")
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
        )
    ]
)
