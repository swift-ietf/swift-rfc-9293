// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

public import Standard_Library_Extensions

extension RFC_9293 {
    /// TCP port number per RFC 9293 Section 3.1
    ///
    /// A 16-bit unsigned integer identifying the sending or receiving process.
    /// Port numbers 0-1023 are well-known ports, 1024-49151 are registered,
    /// and 49152-65535 are dynamic/private.
    ///
    /// ## Binary Format
    ///
    /// Per RFC 9293 Section 3.1, source and destination ports are 16-bit fields
    /// in network byte order (big-endian).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let port = RFC_9293.Port(8080)
    /// let http = RFC_9293.Port.http  // 80
    /// ```
    public struct Port: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: UInt16

        private init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        public init(rawValue: UInt16) {
            self.init(__unchecked: (), rawValue: rawValue)
        }

        public init(_ value: UInt16) {
            self.init(__unchecked: (), rawValue: value)
        }
    }
}

// MARK: - Well-Known Ports

extension RFC_9293.Port {
    /// FTP data port (20)
    public static let ftpData = Self(__unchecked: (), rawValue: 20)

    /// FTP control port (21)
    public static let ftp = Self(__unchecked: (), rawValue: 21)

    /// SSH port (22)
    public static let ssh = Self(__unchecked: (), rawValue: 22)

    /// Telnet port (23)
    public static let telnet = Self(__unchecked: (), rawValue: 23)

    /// SMTP port (25)
    public static let smtp = Self(__unchecked: (), rawValue: 25)

    /// HTTP port (80)
    public static let http = Self(__unchecked: (), rawValue: 80)

    /// HTTPS port (443)
    public static let https = Self(__unchecked: (), rawValue: 443)
}

// MARK: - Classification

extension RFC_9293.Port {
    /// Returns true if this is a well-known port (0-1023)
    public var isWellKnown: Bool { rawValue < 1024 }

    /// Returns true if this is a registered port (1024-49151)
    public var isRegistered: Bool { rawValue >= 1024 && rawValue < 49152 }

    /// Returns true if this is a dynamic/private port (49152-65535)
    public var isDynamic: Bool { rawValue >= 49152 }
}

// MARK: - Byte Parsing

extension RFC_9293.Port {
    /// Creates a Port from bytes (big-endian)
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        var iterator = bytes.makeIterator()

        guard let high = iterator.next() else { throw .empty }
        guard let low = iterator.next() else { throw .insufficientBytes }

        // UInt16 storage is arithmetic-domain; cross the byte-domain boundary
        // via .underlying.
        let value = UInt16(high.underlying) << 8 | UInt16(low.underlying)
        self.init(__unchecked: (), rawValue: value)
    }
}

// MARK: - Binary.Serializable

extension RFC_9293.Port: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ port: RFC_9293.Port,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        buffer.append(contentsOf: port.rawValue.bytes(endianness: .big))
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension RFC_9293.Port: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt16) {
        self.init(value)
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.Port: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}
