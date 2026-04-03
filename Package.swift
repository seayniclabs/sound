// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "Sound",
    platforms: [
        .macOS(.v14)
    ],
    dependencies: [
        .package(url: "https://github.com/modelcontextprotocol/swift-sdk.git", from: "0.11.0")
    ],
    targets: [
        .target(
            name: "SoundCore",
            dependencies: [
                .product(name: "MCP", package: "swift-sdk")
            ],
            path: "Sources/SoundCore"
        ),
        .executableTarget(
            name: "Sound",
            dependencies: [
                "SoundCore",
                .product(name: "MCP", package: "swift-sdk")
            ],
            path: "Sources/Sound",
            exclude: ["Sound.entitlements", "Info.plist"],
            linkerSettings: [
                .unsafeFlags([
                    "-Xlinker", "-sectcreate",
                    "-Xlinker", "__TEXT",
                    "-Xlinker", "__info_plist",
                    "-Xlinker", "Sources/Sound/Info.plist"
                ])
            ]
        ),
        .testTarget(
            name: "SoundTests",
            dependencies: [
                "SoundCore",
                .product(name: "MCP", package: "swift-sdk")
            ],
            path: "Tests/SoundTests"
        )
    ]
)
