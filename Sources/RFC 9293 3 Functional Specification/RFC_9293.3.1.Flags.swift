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

public import Standards

extension RFC_9293.`3`.`1` {
    /// TCP Control Flags per RFC 9293 Section 3.1
    ///
    /// An 8-bit field containing the control bits that manage TCP connections.
    ///
    /// ## Flag Positions
    ///
    /// Per RFC 9293 Section 3.1:
    /// ```
    /// Bit 0: FIN - No more data from sender
    /// Bit 1: SYN - Synchronize sequence numbers
    /// Bit 2: RST - Reset the connection
    /// Bit 3: PSH - Push function
    /// Bit 4: ACK - Acknowledgment field significant
    /// Bit 5: URG - Urgent pointer field significant
    /// Bit 6: ECE - ECN-Echo
    /// Bit 7: CWR - Congestion Window Reduced
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// // SYN segment
    /// let synFlags: RFC_9293.`3`.`1`.Flags = [.syn]
    ///
    /// // SYN-ACK segment
    /// let synAckFlags: RFC_9293.`3`.`1`.Flags = [.syn, .ack]
    /// ```
    public struct Flags: OptionSet, Hashable, Sendable, Codable {
        public let rawValue: UInt8

        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - Flag Constants

extension RFC_9293.`3`.`1`.Flags {
    /// FIN: No more data from sender
    public static let fin = Self(rawValue: 1 << 0)

    /// SYN: Synchronize sequence numbers
    public static let syn = Self(rawValue: 1 << 1)

    /// RST: Reset the connection
    public static let rst = Self(rawValue: 1 << 2)

    /// PSH: Push function
    public static let psh = Self(rawValue: 1 << 3)

    /// ACK: Acknowledgment field significant
    public static let ack = Self(rawValue: 1 << 4)

    /// URG: Urgent pointer field significant
    public static let urg = Self(rawValue: 1 << 5)

    /// ECE: ECN-Echo (ECN-capable)
    public static let ece = Self(rawValue: 1 << 6)

    /// CWR: Congestion Window Reduced
    public static let cwr = Self(rawValue: 1 << 7)
}

// MARK: - Common Combinations

extension RFC_9293.`3`.`1`.Flags {
    /// Empty flags (no control bits set)
    public static let none = Self([])

    /// SYN-ACK flags for connection establishment
    public static let synAck: Self = [.syn, .ack]

    /// FIN-ACK flags for connection termination
    public static let finAck: Self = [.fin, .ack]
}

// MARK: - Binary.Serializable

extension RFC_9293.`3`.`1`.Flags: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ flags: RFC_9293.`3`.`1`.Flags,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        buffer.append(flags.rawValue)
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.`3`.`1`.Flags: CustomStringConvertible {
    public var description: String {
        var parts: [String] = []
        if contains(.cwr) { parts.append("CWR") }
        if contains(.ece) { parts.append("ECE") }
        if contains(.urg) { parts.append("URG") }
        if contains(.ack) { parts.append("ACK") }
        if contains(.psh) { parts.append("PSH") }
        if contains(.rst) { parts.append("RST") }
        if contains(.syn) { parts.append("SYN") }
        if contains(.fin) { parts.append("FIN") }
        return parts.isEmpty ? "none" : parts.joined(separator: "|")
    }
}
