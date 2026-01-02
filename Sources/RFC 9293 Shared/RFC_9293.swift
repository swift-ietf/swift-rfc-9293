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

/// RFC 9293: Transmission Control Protocol (TCP)
///
/// This namespace implements TCP as specified in RFC 9293 (August 2022),
/// which obsoletes RFC 793 and consolidates updates from numerous related RFCs.
///
/// ## Key Types
///
/// - ``Port``: 16-bit TCP port number
/// - ``SequenceNumber``: 32-bit sequence number with modular arithmetic
/// - ``State``: TCP connection state machine
///
/// ## Protocol Overview
///
/// TCP provides reliable, ordered, connection-oriented data transfer.
/// Key characteristics:
/// - Three-way handshake for connection establishment
/// - Sequence numbers for ordering and duplicate detection
/// - Acknowledgments for reliable delivery
/// - Flow control via sliding window
///
/// ## Example
///
/// ```swift
/// let port = RFC_9293.Port(8080)
/// let seq = RFC_9293.SequenceNumber(rawValue: 12345)
/// let nextSeq = seq + 100  // Modular arithmetic
/// ```
///
/// ## See Also
///
/// - [RFC 9293](https://www.rfc-editor.org/rfc/rfc9293)
public enum RFC_9293 {}
