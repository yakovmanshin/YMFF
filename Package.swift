// swift-tools-version: 5.5

import PackageDescription

let package = Package(
    name: "YMFF",
    platforms: [
        .iOS(.v11),
        .macOS(.v10_13),
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
            dependencies: ["YMFFProtocols"]
        ),
        .target(name: "YMFFProtocols"),
        .testTarget(
            name: "YMFFTests",
            dependencies: ["YMFF"]
        ),
    ]
)
