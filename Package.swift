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
    static let standards = Self.product(name: "Standards", package: "swift-standards")
    static let incits41986 = Self.product(name: "INCITS 4 1986", package: "swift-incits-4-1986")
    static let rfc791 = Self.product(name: "RFC 791", package: "swift-rfc-791")
}

let package = Package(
    name: "swift-rfc-9293",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26),
    ],
    products: [
        .library(name: .rfc9293, targets: [.rfc9293]),
        .library(name: .rfc9293Shared, targets: [.rfc9293Shared]),
        .library(name: .rfc9293Section3, targets: [.rfc9293Section3]),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-standards/swift-standards", from: "0.10.0"),
        .package(url: "https://github.com/swift-standards/swift-incits-4-1986", from: "0.6.3"),
        .package(url: "https://github.com/swift-standards/swift-rfc-791", from: "0.1.0"),
    ],
    targets: [
        // Shared types with no dependencies on section targets
        .target(
            name: .rfc9293Shared,
            dependencies: [.standards]
        ),

        // Section 3: Functional Specification
        .target(
            name: .rfc9293Section3,
            dependencies: [.rfc9293Shared, .standards, .incits41986]
        ),

        // High-level API umbrella
        .target(
            name: .rfc9293,
            dependencies: [.rfc9293Shared, .rfc9293Section3, .standards, .rfc791]
        ),

        .testTarget(
            name: .rfc9293.tests,
            dependencies: [.rfc9293]
        ),
    ],
    swiftLanguageModes: [.v6]
)

extension String {
    var tests: Self { self + " Tests" }
}

for target in package.targets where ![.system, .binary, .plugin].contains(target.type) {
    let existing = target.swiftSettings ?? []
    target.swiftSettings = existing + [
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
    ]
}
