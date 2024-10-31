// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkLayer",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "NetworkLayer",
            targets: ["NetworkLayer"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/daltoniam/Starscream", from: "4.0.6")
    ],
    targets: [
        .target(
            name: "NetworkLayer",
            dependencies: [.byName(name: "Starscream")]),

    ]
)
