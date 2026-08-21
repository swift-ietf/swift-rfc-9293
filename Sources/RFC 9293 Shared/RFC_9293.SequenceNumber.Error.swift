extension RFC_9293.SequenceNumber {

    public enum Error: Swift.Error, Sendable, Equatable {
        case insufficientBytes
    }
}

extension RFC_9293.SequenceNumber.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes:
            return "SequenceNumber requires 4 bytes"
        }
    }
}
