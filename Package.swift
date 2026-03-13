// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Stem",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.11.0")
    ],
    targets: [
        .target(
            name: "StemCore",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk")
            ],
            path: "Sources/StemCore"
        ),
        .executableTarget(
            name: "Stem",
            dependencies: [
                "StemCore",
                .product(name: "MCP", package: "swift-sdk")
            ],
            path: "Sources/Stem",
            exclude: ["Stem.entitlements", "Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Stem/Info.plist"
                ])
            ]
        ),
        .testTarget(
            name: "StemTests",
            dependencies: [
                "StemCore",
                .product(name: "MCP", package: "swift-sdk")
            ],
            path: "Tests/StemTests"
        )
    ]
)
