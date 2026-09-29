extension RFC_9293.`3`.`3` {

    public enum Send {}
}

extension RFC_9293.`3`.`3`.Send {

    public struct Variables: Hashable, Sendable {

        public var una: RFC_9293.SequenceNumber

        public var nxt: RFC_9293.SequenceNumber

        public var wnd: UInt16

        public var up: RFC_9293.SequenceNumber

        public var wl1: RFC_9293.SequenceNumber

        public var wl2: RFC_9293.SequenceNumber

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

        public init(iss: RFC_9293.SequenceNumber) {
            self.una = iss
            self.nxt = iss + 1
            self.wnd = 0
            self.up = iss
            self.wl1 = iss
            self.wl2 = iss
            self.iss = iss
        }
    }
}

extension RFC_9293.`3`.`3`.Send.Variables {

    public var windowEnd: RFC_9293.SequenceNumber {
        una + UInt32(wnd)
    }

    public var usableWindow: UInt32 {
        return una + UInt32(wnd) - nxt
    }

    public var isWindowFull: Bool {
        nxt >= windowEnd
    }

    public var flightSize: UInt32 {
        nxt - una
    }
}

extension RFC_9293.`3`.`3`.Send.Variables: CustomStringConvertible {
    public var description: String {
        "SND(UNA=\(una) NXT=\(nxt) WND=\(wnd) ISS=\(iss))"
    }
}
