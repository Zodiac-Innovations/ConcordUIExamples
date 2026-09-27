// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "ConcordUIAndroidApplication",
    products: [
        .library(name: "ConcordUIAndroidApplication", type: .dynamic, targets: ["AndroidBridge"])
    ],
    dependencies: [
        .package(url: "https://github.com/Zodiac-Innovations/ConcordUI.git", branch: "main")
    ],
    targets: [
        .target(
            name: "SharedApplication",
            dependencies: [.product(name: "ConcordUI", package: "ConcordUI")],
            path: "Shared/Swift"
        ),
        .target(
            name: "AndroidBridge",
            dependencies: [
                "SharedApplication",
                .product(name: "ConcordUI", package: "ConcordUI")
            ],
            path: "Android/SwiftBridge"
        )
    ]
)