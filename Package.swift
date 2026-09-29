// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-rfc-9293",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
        .visionOS(.v27),
    ],
    products: [
        .library(name: "RFC 9293", targets: ["RFC 9293"]),
        .library(
            name: "RFC 9293 Standard Library Integration",
            targets: ["RFC 9293 Standard Library Integration"]
        ),
        .library(
            name: "RFC 9293 Foundation Integration",
            targets: ["RFC 9293 Foundation Integration"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-atoms/swift-byte.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-791.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "RFC 9293",
            dependencies: [
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "RFC 791", package: "swift-rfc-791"),
            ]
        ),
        .target(
            name: "RFC 9293 Standard Library Integration",
            dependencies: [
                .target(name: "RFC 9293"),
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),
        .target(
            name: "RFC 9293 Foundation Integration",
            dependencies: [
                .target(name: "RFC 9293")
            ]
        ),
        .testTarget(
            name: "RFC 9293 Tests",
            dependencies: [
                .target(name: "RFC 9293"),
                .product(name: "Byte", package: "swift-byte"),
                .product(name: "RFC 791", package: "swift-rfc-791"),
                .product(name: "RFC 791 Standard Library Integration", package: "swift-rfc-791"),
            ]
        ),
        .testTarget(
            name: "RFC 9293 Standard Library Integration Tests",
            dependencies: [
                .target(name: "RFC 9293"),
                .target(name: "RFC 9293 Standard Library Integration"),
                .product(name: "Byte", package: "swift-byte"),
            ]
        ),
        .testTarget(
            name: "RFC 9293 Foundation Integration Tests",
            dependencies: [
                .target(name: "RFC 9293"),
                .target(name: "RFC 9293 Foundation Integration"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
