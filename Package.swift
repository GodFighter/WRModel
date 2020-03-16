// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "WRModel",
    products: [
        .library(name: "WRModel", targets: ["WRModel"])
    ],
    dependencies: [
        .package(url: "https://github.com/ccgus/fmdb", .revision("9b100cc3dd83ff88a17a4da8718eab4b08e2fe67")),
        .package(url: "https://github.com/kakaopensource/KakaJSON.git", from: "1.1.2"),
    ],
    targets: [
        .target(name: "WRModel", path: "WRModel/Classes")
    ]
)
