extension IETF.RFC.`9293`.`3`.`3` {

    public enum Send {}
}

extension IETF.RFC.`9293`.`3`.`3`.Send {

    public struct Variables: Hashable, Sendable {

        public var una: IETF.RFC.`9293`.SequenceNumber

        public var nxt: IETF.RFC.`9293`.SequenceNumber

        public var wnd: UInt16

        public var up: IETF.RFC.`9293`.SequenceNumber

        public var wl1: IETF.RFC.`9293`.SequenceNumber

        public var wl2: IETF.RFC.`9293`.SequenceNumber

        public let iss: IETF.RFC.`9293`.SequenceNumber

        public init(
            una: IETF.RFC.`9293`.SequenceNumber,
            nxt: IETF.RFC.`9293`.SequenceNumber,
            wnd: UInt16,
            up: IETF.RFC.`9293`.SequenceNumber,
            wl1: IETF.RFC.`9293`.SequenceNumber,
            wl2: IETF.RFC.`9293`.SequenceNumber,
            iss: IETF.RFC.`9293`.SequenceNumber
        ) {
            self.una = una
            self.nxt = nxt
            self.wnd = wnd
            self.up = up
            self.wl1 = wl1
            self.wl2 = wl2
            self.iss = iss
        }

        public init(iss: IETF.RFC.`9293`.SequenceNumber) {
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

extension IETF.RFC.`9293`.`3`.`3`.Send.Variables {

    public var windowEnd: IETF.RFC.`9293`.SequenceNumber {
        una + UInt32(wnd)
    }

    public var usableWindow: UInt32 {
        nxt < windowEnd ? windowEnd - nxt : 0
    }

    public var isWindowFull: Bool {
        nxt >= windowEnd
    }

    public var flightSize: UInt32 {
        nxt - una
    }
}

extension IETF.RFC.`9293`.`3`.`3`.Send.Variables: CustomStringConvertible {
    public var description: String {
        "SND(UNA=\(una) NXT=\(nxt) WND=\(wnd) ISS=\(iss))"
    }
}
