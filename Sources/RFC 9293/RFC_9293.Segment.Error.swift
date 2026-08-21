extension RFC_9293.Segment {

    public enum Error: Swift.Error, Sendable, Equatable {
        case insufficientBytes
        case invalidDataOffset
    }
}

extension RFC_9293.Segment.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes:
            return "Not enough bytes to parse TCP segment"

        case .invalidDataOffset:
            return "Invalid data offset in TCP header"
        }
    }
}
