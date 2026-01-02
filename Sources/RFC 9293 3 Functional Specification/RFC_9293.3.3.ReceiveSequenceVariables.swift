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
    /// Receive Sequence namespace per RFC 9293 Section 3.3.1
    public enum Receive {}
}

extension RFC_9293.`3`.`3`.Receive {
    /// Receive Sequence Variables per RFC 9293 Section 3.3.1
    ///
    /// These variables track the state of incoming data.
    ///
    /// ## Variables
    ///
    /// Per RFC 9293:
    /// - RCV.NXT: Receive next
    /// - RCV.WND: Receive window
    /// - RCV.UP: Receive urgent pointer
    /// - IRS: Initial receive sequence number
    ///
    /// ## Receive Sequence Space
    ///
    /// ```
    ///      1          2          3
    /// ----------|----------|----------
    ///        RCV.NXT    RCV.NXT
    ///                   +RCV.WND
    ///
    /// 1 - old sequence numbers already acknowledged
    /// 2 - sequence numbers allowed for new reception
    /// 3 - future sequence numbers not yet allowed
    /// ```
    public struct Variables: Hashable, Sendable {
        /// Receive next - next sequence number expected on incoming segment
        public var nxt: RFC_9293.SequenceNumber

        /// Receive window - the receive window size
        public var wnd: UInt16

        /// Receive urgent pointer
        public var up: RFC_9293.SequenceNumber

        /// Initial receive sequence number
        public let irs: RFC_9293.SequenceNumber

        public init(
            nxt: RFC_9293.SequenceNumber,
            wnd: UInt16,
            up: RFC_9293.SequenceNumber,
            irs: RFC_9293.SequenceNumber
        ) {
            self.nxt = nxt
            self.wnd = wnd
            self.up = up
            self.irs = irs
        }

        /// Creates initial receive variables with the given IRS
        public init(irs: RFC_9293.SequenceNumber, windowSize: UInt16) {
            self.nxt = irs + 1  // After SYN
            self.wnd = windowSize
            self.up = irs
            self.irs = irs
        }
    }
}

// MARK: - Computed Properties

extension RFC_9293.`3`.`3`.Receive.Variables {
    /// The right edge of the receive window (RCV.NXT + RCV.WND)
    public var windowEnd: RFC_9293.SequenceNumber {
        nxt + UInt32(wnd)
    }

    /// Returns true if a sequence number is within the receive window
    public func isInWindow(_ seq: RFC_9293.SequenceNumber) -> Bool {
        seq.isWithin(left: nxt, right: windowEnd)
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.`3`.`3`.Receive.Variables: CustomStringConvertible {
    public var description: String {
        "RCV(NXT=\(nxt) WND=\(wnd) IRS=\(irs))"
    }
}
