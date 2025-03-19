// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftSensorsApp",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .executable(name: "SwiftSensorsApp", targets: ["SwiftSensorsApp"]),
    ],
    dependencies: [
        .package(path: "../"),
    ],
    targets: [
        .executableTarget(
            name: "SwiftSensorsApp",
            dependencies: [
                .product(name: "SwiftSensors", package: "swift-sensors"),
            ],
            path: "SwiftSensorsApp",
            resources: [
                .process("Assets.xcassets"),
                .process("Preview Content/Preview Assets.xcassets"),
            ]
        ),
        .testTarget(
            name: "SwiftSensorsAppTests",
            dependencies: ["SwiftSensorsApp"],
            path: "SwiftSensorsAppTests"
        ),
    ],
    swiftLanguageVersions: [.v5]
)