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

extension RFC_9293.`3`.`1` {
    /// Data Offset field per RFC 9293 Section 3.1
    ///
    /// A 4-bit field indicating the number of 32-bit words in the TCP header.
    /// This indicates where the data begins. The minimum value is 5 (20 bytes)
    /// and the maximum is 15 (60 bytes).
    ///
    /// ## Binary Format
    ///
    /// The data offset occupies bits 96-99 of the TCP header (high nibble of byte 12).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let offset = RFC_9293.`3`.`1`.DataOffset.minimum  // 5 (20 bytes)
    /// print(offset.headerLength)  // 20
    /// ```
    public struct DataOffset: Hashable, Sendable, Codable {
        /// Raw 4-bit value (number of 32-bit words)
        public let rawValue: UInt8

        private init(__unchecked: Void, rawValue: UInt8) {
            self.rawValue = rawValue
        }

        /// Creates a DataOffset from a raw 4-bit value
        ///
        /// - Parameter rawValue: Number of 32-bit words (must be 5-15)
        /// - Throws: `Error.valueTooSmall` if less than 5
        /// - Throws: `Error.valueTooLarge` if greater than 15
        public init(rawValue: UInt8) throws(Error) {
            guard rawValue >= 5 else { throw .valueTooSmall }
            guard rawValue <= 15 else { throw .valueTooLarge }
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Constants

extension RFC_9293.`3`.`1`.DataOffset {
    /// Minimum data offset (5 words = 20 bytes, no options)
    public static let minimum = Self(__unchecked: (), rawValue: 5)

    /// Maximum data offset (15 words = 60 bytes)
    public static let maximum = Self(__unchecked: (), rawValue: 15)
}

// MARK: - Computed Properties

extension RFC_9293.`3`.`1`.DataOffset {
    /// The header length in bytes
    public var headerLength: Int {
        Int(rawValue) * 4
    }

    /// The options length in bytes (header length minus 20-byte minimum)
    public var optionsLength: Int {
        headerLength - 20
    }
}

// MARK: - Factory Methods

extension RFC_9293.`3`.`1`.DataOffset {
    /// Creates a DataOffset from the header length in bytes
    ///
    /// - Parameter bytes: Header length in bytes (must be 20-60, multiple of 4)
    /// - Throws: Appropriate error if validation fails
    public static func fromHeaderLength(_ bytes: Int) throws(Error) -> Self {
        guard bytes >= 20 else { throw .valueTooSmall }
        guard bytes <= 60 else { throw .valueTooLarge }
        guard bytes % 4 == 0 else { throw .notAligned }
        return Self(__unchecked: (), rawValue: UInt8(bytes / 4))
    }
}

// MARK: - Binary.Serializable

extension RFC_9293.`3`.`1`.DataOffset: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ offset: RFC_9293.`3`.`1`.DataOffset,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        // Data offset is 4 bits, upper nibble when combined with reserved bits
        buffer.append(offset.rawValue << 4)
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.`3`.`1`.DataOffset: CustomStringConvertible {
    public var description: String {
        "\(rawValue) (\(headerLength) bytes)"
    }
}
