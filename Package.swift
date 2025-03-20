// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "SwiftSensors",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "SwiftSensors",
            targets: ["SwiftSensors"]
        )
    ],
    dependencies: [
    ],
    targets: [
        .binaryTarget(
            name: "IOKit",
            path: "Frameworks/IOKit.xcframework"
        ),
        .target(
            name: "PrivateAPI",
            dependencies: ["IOKit"],
            publicHeadersPath: "."
        ),
        .target(
            name: "SwiftSensors",
            dependencies: ["PrivateAPI"]
        )
    ]
)
