# swift-rfc-9293

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

The TCP segment format and connection semantics of RFC 9293.

## Standard Reference

- **RFC**: 9293
- **Title**: Transmission Control Protocol (TCP)

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-9293.git", from: "0.1.0")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 9293", package: "swift-rfc-9293")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
