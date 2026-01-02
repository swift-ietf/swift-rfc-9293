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

extension RFC_9293 {
    /// TCP protocol number for use in IP headers
    ///
    /// Per RFC 9293, TCP uses protocol number 6 in the IP header's
    /// protocol field.
    public static let protocolNumber: UInt8 = 6

    /// Minimum header size in bytes (no options)
    ///
    /// The TCP header is at minimum 20 bytes (5 32-bit words).
    public static let minimumHeaderSize: Int = 20

    /// Maximum header size in bytes (with options)
    ///
    /// The TCP header can be at most 60 bytes (15 32-bit words).
    public static let maximumHeaderSize: Int = 60

    /// Maximum Segment Lifetime in seconds
    ///
    /// Per RFC 9293 Section 3.4.1, MSL is the time a TCP segment can
    /// exist in the network. Typically 2 minutes.
    public static let mslSeconds: UInt32 = 120

    /// TIME-WAIT duration in seconds
    ///
    /// Per RFC 9293 Section 3.6.1, TIME-WAIT is 2 * MSL.
    public static let timeWaitDurationSeconds: UInt32 = 2 * mslSeconds

    /// Default MSS for IPv4
    ///
    /// Per RFC 9293 Section 3.7.1: 536 octets (576 - 20 IP - 20 TCP)
    public static let defaultMSSIPv4: UInt16 = 536

    /// Default MSS for IPv6
    ///
    /// Per RFC 9293 Section 3.7.1: 1220 octets (1280 - 40 IPv6 - 20 TCP)
    public static let defaultMSSIPv6: UInt16 = 1220
}
