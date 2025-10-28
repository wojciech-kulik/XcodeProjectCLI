// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "XcodeProjectCLI",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "xcodeproj",
            targets: ["XcodeProjectCLI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/tuist/XcodeProj.git", .upToNextMajor(from: "8.12.0")),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.5.0")
    ],
    targets: [
        .executableTarget(
            name: "XcodeProjectCLI",
            dependencies: [
                "XcodeProj",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)
