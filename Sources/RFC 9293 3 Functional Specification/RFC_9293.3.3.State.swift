extension RFC_9293.`3`.`3` {

    public enum State: String, Hashable, Sendable, Codable, CaseIterable {

        case closed = "CLOSED"

        case listen = "LISTEN"

        case synSent = "SYN-SENT"

        case synReceived = "SYN-RECEIVED"

        case established = "ESTABLISHED"

        case finWait1 = "FIN-WAIT-1"

        case finWait2 = "FIN-WAIT-2"

        case closeWait = "CLOSE-WAIT"

        case closing = "CLOSING"

        case lastAck = "LAST-ACK"

        case timeWait = "TIME-WAIT"
    }
}

extension RFC_9293.`3`.`3`.State {

    public var canSendData: Bool {
        switch self {
        case .established, .closeWait:
            return true

        default:
            return false
        }
    }

    public var canReceiveData: Bool {
        switch self {
        case .established, .finWait1, .finWait2:
            return true

        default:
            return false
        }
    }

    public var isSynchronized: Bool {
        switch self {
        case .established, .finWait1, .finWait2, .closeWait, .closing, .lastAck, .timeWait:
            return true

        default:
            return false
        }
    }

    public var isClosing: Bool {
        switch self {
        case .finWait1, .finWait2, .closing, .lastAck, .timeWait:
            return true

        default:
            return false
        }
    }
}

extension RFC_9293.`3`.`3`.State: CustomStringConvertible {
    public var description: String {
        rawValue
    }
}
