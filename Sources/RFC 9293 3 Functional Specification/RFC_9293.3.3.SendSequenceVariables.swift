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
    /// Send Sequence namespace per RFC 9293 Section 3.3.1
    public enum Send {}
}

extension RFC_9293.`3`.`3`.Send {
    /// Send Sequence Variables per RFC 9293 Section 3.3.1
    ///
    /// These variables track the state of outgoing data.
    ///
    /// ## Variables
    ///
    /// Per RFC 9293:
    /// - SND.UNA: Send unacknowledged
    /// - SND.NXT: Send next
    /// - SND.WND: Send window
    /// - SND.UP: Send urgent pointer
    /// - SND.WL1: Segment sequence number used for last window update
    /// - SND.WL2: Segment acknowledgment number used for last window update
    /// - ISS: Initial send sequence number
    ///
    /// ## Send Sequence Space
    ///
    /// ```
    ///      1         2          3          4
    /// ----------|----------|----------|----------
    ///        SND.UNA    SND.NXT    SND.UNA
    ///                              +SND.WND
    ///
    /// 1 - old sequence numbers acknowledged
    /// 2 - sequence numbers of unacknowledged data
    /// 3 - sequence numbers allowed for new data transmission
    /// 4 - future sequence numbers not yet allowed
    /// ```
    public struct Variables: Hashable, Sendable {
        /// Send unacknowledged - oldest unacknowledged sequence number
        public var una: RFC_9293.SequenceNumber

        /// Send next - next sequence number to send
        public var nxt: RFC_9293.SequenceNumber

        /// Send window - the send window size
        public var wnd: UInt16

        /// Send urgent pointer
        public var up: RFC_9293.SequenceNumber

        /// Segment sequence number used for last window update
        public var wl1: RFC_9293.SequenceNumber

        /// Segment acknowledgment number used for last window update
        public var wl2: RFC_9293.SequenceNumber

        /// Initial send sequence number
        public let iss: RFC_9293.SequenceNumber

        public init(
            una: RFC_9293.SequenceNumber,
            nxt: RFC_9293.SequenceNumber,
            wnd: UInt16,
            up: RFC_9293.SequenceNumber,
            wl1: RFC_9293.SequenceNumber,
            wl2: RFC_9293.SequenceNumber,
            iss: RFC_9293.SequenceNumber
        ) {
            self.una = una
            self.nxt = nxt
            self.wnd = wnd
            self.up = up
            self.wl1 = wl1
            self.wl2 = wl2
            self.iss = iss
        }

        /// Creates initial send variables with the given ISS
        public init(iss: RFC_9293.SequenceNumber) {
            self.una = iss
            self.nxt = iss + 1  // After SYN
            self.wnd = 0
            self.up = iss
            self.wl1 = iss
            self.wl2 = iss
            self.iss = iss
        }
    }
}

// MARK: - Computed Properties

extension RFC_9293.`3`.`3`.Send.Variables {
    /// The right edge of the send window (SND.UNA + SND.WND)
    public var windowEnd: RFC_9293.SequenceNumber {
        una + UInt32(wnd)
    }

    /// Amount of data that can be sent (usable window)
    public var usableWindow: UInt32 {
        let available = una + UInt32(wnd) - nxt
        return available
    }

    /// Returns true if the send window is full
    public var isWindowFull: Bool {
        nxt >= windowEnd
    }

    /// Amount of unacknowledged data in flight
    public var flightSize: UInt32 {
        nxt - una
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.`3`.`3`.Send.Variables: CustomStringConvertible {
    public var description: String {
        "SND(UNA=\(una) NXT=\(nxt) WND=\(wnd) ISS=\(iss))"
    }
}
