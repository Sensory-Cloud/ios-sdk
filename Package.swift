// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SensoryCloud",
    platforms: [.iOS(.v14)],
    products: [
        .library(
            name: "SensoryCloud",
            targets: ["SensoryCloud"])
    ],
    dependencies: [
        .package(url: "https://github.com/grpc/grpc-swift.git", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "SensoryCloud",
            dependencies: [.product(name: "GRPC", package: "grpc-swift")]),
        .testTarget(
            name: "SensoryCloudTests",
            dependencies: ["SensoryCloud"],
            resources: [.process("Resources")])
    ]
)
