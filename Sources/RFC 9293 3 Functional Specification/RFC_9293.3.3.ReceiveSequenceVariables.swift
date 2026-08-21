extension RFC_9293.`3`.`3` {

    public enum Receive {}
}

extension RFC_9293.`3`.`3`.Receive {

    public struct Variables: Hashable, Sendable {

        public var nxt: RFC_9293.SequenceNumber

        public var wnd: UInt16

        public var up: RFC_9293.SequenceNumber

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

        public init(irs: RFC_9293.SequenceNumber, windowSize: UInt16) {
            self.nxt = irs + 1
            self.wnd = windowSize
            self.up = irs
            self.irs = irs
        }
    }
}

extension RFC_9293.`3`.`3`.Receive.Variables {

    public var windowEnd: RFC_9293.SequenceNumber {
        nxt + UInt32(wnd)
    }

    public func isInWindow(_ seq: RFC_9293.SequenceNumber) -> Bool {
        seq.isWithin(left: nxt, right: windowEnd)
    }
}

extension RFC_9293.`3`.`3`.Receive.Variables: CustomStringConvertible {
    public var description: String {
        "RCV(NXT=\(nxt) WND=\(wnd) IRS=\(irs))"
    }
}
