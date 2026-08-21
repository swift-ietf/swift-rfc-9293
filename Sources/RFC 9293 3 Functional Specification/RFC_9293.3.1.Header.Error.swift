extension RFC_9293.`3`.`1`.Header {

    public enum Error: Swift.Error, Sendable, Equatable {
        case insufficientBytes
        case dataOffsetTooSmall
        case dataOffsetTooLarge
    }
}

extension RFC_9293.`3`.`1`.Header.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes:
            return "TCP header requires at least 20 bytes"

        case .dataOffsetTooSmall:
            return "Data offset must be at least 5 (20 bytes)"

        case .dataOffsetTooLarge:
            return "Data offset cannot exceed 15 (60 bytes)"
        }
    }
}
