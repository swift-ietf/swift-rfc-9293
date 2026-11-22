extension IETF.RFC.`9293`.`3`.`3` {

    public enum Receive {}
}

extension IETF.RFC.`9293`.`3`.`3`.Receive {

    public struct Variables: Hashable, Sendable {

        public var nxt: IETF.RFC.`9293`.SequenceNumber

        public var wnd: UInt16

        public var up: IETF.RFC.`9293`.SequenceNumber

        public let irs: IETF.RFC.`9293`.SequenceNumber

        public init(
            nxt: IETF.RFC.`9293`.SequenceNumber,
            wnd: UInt16,
            up: IETF.RFC.`9293`.SequenceNumber,
            irs: IETF.RFC.`9293`.SequenceNumber
        ) {
            self.nxt = nxt
            self.wnd = wnd
            self.up = up
            self.irs = irs
        }

        public init(irs: IETF.RFC.`9293`.SequenceNumber, windowSize: UInt16) {
            self.nxt = irs + 1
            self.wnd = windowSize
            self.up = irs
            self.irs = irs
        }
    }
}

extension IETF.RFC.`9293`.`3`.`3`.Receive.Variables {

    public var windowEnd: IETF.RFC.`9293`.SequenceNumber {
        nxt + UInt32(wnd)
    }

    public func isInWindow(_ seq: IETF.RFC.`9293`.SequenceNumber) -> Bool {
        nxt <= seq && seq < windowEnd
    }
}

extension IETF.RFC.`9293`.`3`.`3`.Receive.Variables: CustomStringConvertible {
    public var description: String {
        "RCV(NXT=\(nxt) WND=\(wnd) IRS=\(irs))"
    }
}
