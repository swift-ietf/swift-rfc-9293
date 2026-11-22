extension IETF.RFC.`9293`.SequenceNumber {

    public enum Error: Swift::Error, Sendable, Equatable {
        case insufficientBytes
    }
}

extension IETF.RFC.`9293`.SequenceNumber.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes:
            return "Sequence number requires 4 bytes"
        }
    }
}
