// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "YMFF",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
    ],
    products: [
        .library(
            name: "YMFF",
            targets: ["YMFF"]
        ),
    ],
    targets: [
        .target(
            name: "YMFF",
            dependencies: ["YMFFProtocols"],
            swiftSettings: swiftSettings
        ),
        .target(name: "YMFFProtocols", swiftSettings: swiftSettings),
        .testTarget(
            name: "YMFFTests",
            dependencies: ["YMFF"],
            swiftSettings: swiftSettings
        ),
    ]
)

fileprivate let swiftSettings: [SwiftSetting] = [
    .enableExperimentalFeature("StrictConcurrency"),
    .enableUpcomingFeature("StrictConcurrency"),
]
