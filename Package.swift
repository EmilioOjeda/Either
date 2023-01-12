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
