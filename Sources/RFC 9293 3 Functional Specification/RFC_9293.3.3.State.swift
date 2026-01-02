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

extension RFC_9293.`3`.`3` {
    /// TCP Connection State per RFC 9293 Section 3.3.2
    ///
    /// The TCP state machine has 11 states that govern connection establishment,
    /// data transfer, and connection termination.
    ///
    /// ## State Diagram
    ///
    /// ```
    ///                            +---------+
    ///                            |  CLOSED |
    ///                            +---------+
    ///                              |     |
    ///               passive open   |     |  active open
    ///               -----------    |     |  -----------
    ///                create TCB    |     |  create TCB
    ///                              v     v  send SYN
    ///                          +-----------+
    ///                          |  LISTEN   |
    ///                          +-----------+
    ///               rcv SYN        |     |     rcv SYN
    ///              -----------     |     |    -----------
    ///              send SYN,ACK    |     |    send SYN,ACK
    ///                              v     v
    ///                         +------------+
    ///   rcv SYN,ACK           |  SYN-RCVD  |           rcv SYN,ACK
    ///   ---------             +------------+           ---------
    ///   send ACK                 |      |              send ACK
    ///        +-------------------+      +------------------+
    ///        |                                             |
    ///        v                                             v
    ///   +---------+                                   +---------+
    ///   |SYN-SENT |                                   |ESTAB-   |
    ///   +---------+                                   |LISHED   |
    ///                                                 +---------+
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// var state = RFC_9293.`3`.`3`.State.closed
    /// state = .listen  // Passive open
    /// state = .synReceived  // Received SYN
    /// state = .established  // Connection established
    /// ```
    public enum State: String, Hashable, Sendable, Codable, CaseIterable {
        /// Connection does not exist
        case closed = "CLOSED"

        /// Waiting for connection request from remote TCP
        case listen = "LISTEN"

        /// Waiting for matching connection request after having sent one
        case synSent = "SYN-SENT"

        /// Waiting for confirming connection request acknowledgment
        case synReceived = "SYN-RECEIVED"

        /// Connection is open; data can be exchanged
        case established = "ESTABLISHED"

        /// Waiting for remote TCP connection termination request
        case finWait1 = "FIN-WAIT-1"

        /// Waiting for connection termination from remote TCP
        case finWait2 = "FIN-WAIT-2"

        /// Waiting for connection termination request from local user
        case closeWait = "CLOSE-WAIT"

        /// Waiting for connection termination acknowledgment from remote TCP
        case closing = "CLOSING"

        /// Waiting for acknowledgment of connection termination request sent to remote TCP
        case lastAck = "LAST-ACK"

        /// Waiting for enough time to pass to ensure remote TCP received acknowledgment
        case timeWait = "TIME-WAIT"
    }
}

// MARK: - State Classification

extension RFC_9293.`3`.`3`.State {
    /// Returns true if this state allows sending data
    public var canSendData: Bool {
        switch self {
        case .established, .closeWait:
            return true
        default:
            return false
        }
    }

    /// Returns true if this state allows receiving data
    public var canReceiveData: Bool {
        switch self {
        case .established, .finWait1, .finWait2:
            return true
        default:
            return false
        }
    }

    /// Returns true if this is a synchronized state (connection established)
    public var isSynchronized: Bool {
        switch self {
        case .established, .finWait1, .finWait2, .closeWait, .closing, .lastAck, .timeWait:
            return true
        default:
            return false
        }
    }

    /// Returns true if this state is part of the closing sequence
    public var isClosing: Bool {
        switch self {
        case .finWait1, .finWait2, .closing, .lastAck, .timeWait:
            return true
        default:
            return false
        }
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.`3`.`3`.State: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
