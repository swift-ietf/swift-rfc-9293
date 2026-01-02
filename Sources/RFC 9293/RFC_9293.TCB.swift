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

public import RFC_791

extension RFC_9293 {
    /// Transmission Control Block per RFC 9293 Section 3.3.1
    ///
    /// The TCB stores all the state needed to manage a TCP connection.
    ///
    /// ## Contents
    ///
    /// Per RFC 9293 Section 3.3.1:
    /// - Local and remote socket information
    /// - Connection state
    /// - Send and receive sequence variables
    /// - Retransmission queue pointers
    /// - Current segment information
    ///
    /// ## Example
    ///
    /// ```swift
    /// let tcb = RFC_9293.TCB(
    ///     local: .init(address: RFC_791.IPv4.Address(192, 168, 1, 1), port: 8080),
    ///     remote: .init(address: RFC_791.IPv4.Address(192, 168, 1, 2), port: .http),
    ///     state: .synSent,
    ///     send: .init(iss: initialSeq),
    ///     receive: nil  // Not yet synchronized
    /// )
    /// ```
    public struct TCB: Sendable {
        /// Local socket information
        public let local: Socket

        /// Remote socket information
        public let remote: Socket

        /// Current connection state
        public var state: `3`.`3`.State

        /// Send sequence variables
        public var send: `3`.`3`.Send.Variables

        /// Receive sequence variables (nil until IRS is known)
        public var receive: `3`.`3`.Receive.Variables?

        /// Maximum segment size for sending
        public var sendMSS: UInt16

        /// Maximum segment size for receiving
        public var receiveMSS: UInt16

        public init(
            local: Socket,
            remote: Socket,
            state: `3`.`3`.State,
            send: `3`.`3`.Send.Variables,
            receive: `3`.`3`.Receive.Variables?,
            sendMSS: UInt16 = RFC_9293.defaultMSSIPv4,
            receiveMSS: UInt16 = RFC_9293.defaultMSSIPv4
        ) {
            self.local = local
            self.remote = remote
            self.state = state
            self.send = send
            self.receive = receive
            self.sendMSS = sendMSS
            self.receiveMSS = receiveMSS
        }
    }
}

// MARK: - Socket

extension RFC_9293.TCB {
    /// Socket identifier (IPv4 address + port)
    public struct Socket: Hashable, Sendable {
        /// IPv4 address
        public let address: RFC_791.IPv4.Address

        /// TCP port
        public let port: RFC_9293.Port

        public init(address: RFC_791.IPv4.Address, port: RFC_9293.Port) {
            self.address = address
            self.port = port
        }
    }
}

// MARK: - Connection Tuple

extension RFC_9293.TCB {
    /// The connection 4-tuple identifying this connection
    public var connectionTuple: Connection {
        Connection(local: local, remote: remote)
    }
}

extension RFC_9293.TCB {
    /// Connection identifier (local + remote socket pair)
    public struct Connection: Hashable, Sendable {
        public let local: Socket
        public let remote: Socket

        public init(local: Socket, remote: Socket) {
            self.local = local
            self.remote = remote
        }
    }
}

// MARK: - Computed Properties

extension RFC_9293.TCB {
    /// Returns true if the connection is synchronized
    public var isSynchronized: Bool {
        state.isSynchronized
    }

    /// Returns true if we can send data
    public var canSend: Bool {
        state.canSendData
    }

    /// Returns true if we can receive data
    public var canReceive: Bool {
        state.canReceiveData
    }

    /// The effective MSS for sending (minimum of negotiated values)
    public var effectiveMSS: UInt16 {
        min(sendMSS, receiveMSS)
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.TCB: CustomStringConvertible {
    public var description: String {
        "TCB[\(state)] \(local.port)→\(remote.port) \(send) \(receive?.description ?? "RCV(--)")"
    }
}

extension RFC_9293.TCB.Socket: CustomStringConvertible {
    public var description: String {
        "\(address):\(port)"
    }
}
