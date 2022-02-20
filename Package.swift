// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "YMFF",
    platforms: [
        .macOS(.v10_13),
        .iOS(.v11),
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
