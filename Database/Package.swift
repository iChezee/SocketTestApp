// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Database",
    platforms: [.iOS(.v17)],
    products: [
        .library(
            name: "Database",
            targets: ["Database"]),
    ],
    targets: [
        .target(
            name: "Database"),

    ]
)
