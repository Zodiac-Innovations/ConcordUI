// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ConcordUIAndroidGenerator",
    platforms: [.macOS(.v13)],
    products: [.executable(name: "concordui-android-generate", targets: ["AndroidGenerator"])],
    targets: [
        .executableTarget(name: "AndroidGenerator"),
        .testTarget(name: "AndroidGeneratorTests", dependencies: ["AndroidGenerator"])
    ]
)
