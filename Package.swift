// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "Either",
    products: [
        .library(
            name: "Either",
            targets: ["Either"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0"),
    ],
    targets: [
        .target(
            name: "Either"
        ),
        .testTarget(
            name: "EitherTests",
            dependencies: ["Either"]
        ),
    ]
)
