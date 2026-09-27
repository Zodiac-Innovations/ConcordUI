// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "ConcordUI",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v15),
        .watchOS(.v8),
        .visionOS(.v1)
    ],
    products: [
        .library(name: "ConcordUI", targets: ["ConcordUI"]),
        .library(name: "ConcordUIApple", targets: ["ConcordUIApple"])
    ],
    targets: [
        .target(name: "ConcordUI"),
        .target(
            name: "ConcordUIApple",
            dependencies: ["ConcordUI"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ConcordUITests",
            dependencies: ["ConcordUI"],
            path: "Tests/ConcordUITests"
        )
    ]
)
