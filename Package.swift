// swift-tools-version: 6.2
import PackageDescription

extension String {
    static let rfc9293 = "RFC 9293"
    static let rfc9293Shared = "RFC 9293 Shared"
    static let rfc9293Section3 = "RFC 9293 3 Functional Specification"
}

extension Target.Dependency {
    static let rfc9293 = Self.target(name: .rfc9293)
    static let rfc9293Shared = Self.target(name: .rfc9293Shared)
    static let rfc9293Section3 = Self.target(name: .rfc9293Section3)
    static let standards = Self.product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    static let binary = Self.product(name: "Binary Primitives", package: "swift-binary-primitives")
    static let incits41986 = Self.product(name: "ASCII", package: "swift-ascii")
    static let rfc791 = Self.product(name: "RFC 791", package: "swift-rfc-791")
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
        .library(name: "RFC 9293 3 Functional Specification", targets: ["RFC 9293 3 Functional Specification"])
    ],
    dependencies: [
        .package(path: "../../swift-primitives/swift-standard-library-extensions"),
        .package(path: "../../swift-primitives/swift-binary-primitives"),
        .package(path: "../../swift-foundations/swift-ascii"),
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
        .testTarget(
            name: "RFC 9293 Tests",
            dependencies: [
                "RFC 9293",
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
        .enableExperimentalFeature("SuppressedAssociatedTypesWithDefaults"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
