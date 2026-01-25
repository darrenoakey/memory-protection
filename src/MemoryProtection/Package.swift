// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "MemoryProtection",
    platforms: [
        .macOS(.v13)
    ],
    targets: [
        .executableTarget(
            name: "MemoryProtection",
            path: "Sources/MemoryProtection"
        )
    ]
)
