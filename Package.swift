// swift-tools-version: 6.2
import PackageDescription

extension String {
    static let rfc9293 = "RFC 9293"
    static let rfc9293Shared = "RFC 9293 Shared"
    static let rfc9293Section3 = "RFC 9293 3 Functional Specification"
    static let rfc9293SLI = "RFC 9293 Standard Library Integration"
}

extension Target.Dependency {
    static let rfc9293 = Self.target(name: .rfc9293)
    static let rfc9293Shared = Self.target(name: .rfc9293Shared)
    static let rfc9293Section3 = Self.target(name: .rfc9293Section3)
    static let standards = Self.product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    static let binary = Self.product(name: "Binary Primitives", package: "swift-binary-primitives")
    static let incits41986 = Self.product(name: "ASCII Primitives", package: "swift-ascii-primitives")
    static let rfc791 = Self.product(name: "RFC 791", package: "swift-rfc-791")
    static let bytePrimitivesSLI = Self.product(name: "Byte Primitives Standard Library Integration", package: "swift-byte-primitives")
}

let package = Package(
    name: "swift-rfc-9293",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: "RFC 9293", targets: ["RFC 9293"]),
        .library(name: "RFC 9293 Shared", targets: ["RFC 9293 Shared"]),
        .library(name: "RFC 9293 3 Functional Specification", targets: ["RFC 9293 3 Functional Specification"]),
        .library(name: "RFC 9293 Standard Library Integration", targets: ["RFC 9293 Standard Library Integration"])
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-binary-primitives"),
        .package(path: "../../swift-primitives/swift-byte-primitives"),
        .package(path: "../../swift-primitives/swift-ascii-primitives"),
        .package(path: "../swift-rfc-791")
    ],
    targets: [
        // Shared types with no dependencies on section targets
        .target(
            name: "RFC 9293 Shared",
            dependencies: [.standards, .binary]
        ),

        // Section 3: Functional Specification
        .target(
            name: "RFC 9293 3 Functional Specification",
            dependencies: [.rfc9293Shared, .standards, .incits41986]
        ),

        // High-level API umbrella
        .target(
            name: "RFC 9293",
            dependencies: [.rfc9293Shared, .rfc9293Section3, .standards, .rfc791]
        ),

        // Stdlib-interop forwarders per [API-BYTE-007]
        .target(
            name: "RFC 9293 Standard Library Integration",
            dependencies: [.rfc9293, .rfc9293Section3, .bytePrimitivesSLI]
        ),
        .testTarget(
            name: "RFC 9293 Tests",
            dependencies: [
                "RFC 9293",
            ]
        ),
        .testTarget(
            name: "RFC 9293 Standard Library Integration Tests",
            dependencies: [
                "RFC 9293",
                "RFC 9293 Standard Library Integration",
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
