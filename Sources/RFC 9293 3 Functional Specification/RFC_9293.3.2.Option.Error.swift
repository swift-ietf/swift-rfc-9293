extension RFC_9293.`3`.`2`.Option {

    public enum Error: Swift.Error, Sendable, Equatable {
        case insufficientBytes
        case invalidLength
    }
}

extension RFC_9293.`3`.`2`.Option.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes:
            return "Not enough bytes to parse TCP option"

        case .invalidLength:
            return "Invalid option length"
        }
    }
}
