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
    /// 32-bit TCP Sequence Number with modular arithmetic
    ///
    /// Per RFC 9293 Section 3.4:
    /// > Sequence numbers are 32-bit unsigned integers and wrap around after 2^32 - 1.
    /// > Comparisons must use modular arithmetic.
    ///
    /// ## Modular Arithmetic
    ///
    /// TCP sequence numbers wrap around, so comparisons use signed arithmetic
    /// to determine ordering. A sequence number `a` is "less than" `b` if
    /// `(a - b)` interpreted as a signed 32-bit integer is negative.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let seq = RFC_9293.SequenceNumber(rawValue: 100)
    /// let next = seq + 1500  // Modular addition
    ///
    /// // Comparison handles wraparound
    /// let high = RFC_9293.SequenceNumber(rawValue: .max)
    /// let low = RFC_9293.SequenceNumber(rawValue: 1)
    /// print(high < low)  // true (wrapped around)
    /// ```
    public struct SequenceNumber: RawRepresentable, Hashable, Sendable, Codable {
        public let rawValue: UInt32

        private init(__unchecked: Void, rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public init(rawValue: UInt32) {
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

// MARK: - Modular Arithmetic

extension RFC_9293.SequenceNumber: Comparable {
    /// Modular less-than comparison per RFC 9293 Section 3.4
    ///
    /// Returns true if `lhs` is "less than" `rhs` in sequence space,
    /// accounting for wraparound using signed arithmetic.
    public static func < (lhs: Self, rhs: Self) -> Bool {
        Int32(bitPattern: lhs.rawValue &- rhs.rawValue) < 0
    }
}

extension RFC_9293.SequenceNumber {
    /// Modular addition
    public static func + (lhs: Self, rhs: UInt32) -> Self {
        Self(rawValue: lhs.rawValue &+ rhs)
    }

    /// Modular addition assignment
    public static func += (lhs: inout Self, rhs: UInt32) {
        lhs = lhs + rhs
    }

    /// Modular subtraction (returns difference)
    public static func - (lhs: Self, rhs: Self) -> UInt32 {
        lhs.rawValue &- rhs.rawValue
    }
}

// MARK: - Sequence Space Operations

extension RFC_9293.SequenceNumber {
    /// Returns true if this sequence number is within [left, right] (inclusive)
    ///
    /// Handles wraparound correctly.
    public func isWithin(left: Self, right: Self) -> Bool {
        left <= self && self <= right
    }

    /// Returns true if this sequence number is within (left, right) (exclusive)
    public func isBetween(left: Self, right: Self) -> Bool {
        left < self && self < right
    }
}

// MARK: - Byte Parsing

extension RFC_9293.SequenceNumber {
    /// Creates a SequenceNumber from bytes (big-endian)
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == UInt8 {
        guard bytes.count >= 4 else { throw .insufficientBytes }

        var iterator = bytes.makeIterator()
        let b0 = iterator.next()!
        let b1 = iterator.next()!
        let b2 = iterator.next()!
        let b3 = iterator.next()!

        let value = UInt32(b0) << 24 | UInt32(b1) << 16 | UInt32(b2) << 8 | UInt32(b3)
        self.init(__unchecked: (), rawValue: value)
    }
}

// MARK: - Binary.Serializable

extension RFC_9293.SequenceNumber: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ seq: RFC_9293.SequenceNumber,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(contentsOf: seq.rawValue.bytes(endianness: .big))
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.SequenceNumber: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}
