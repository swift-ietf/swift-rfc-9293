extension RFC_9293.`3`.`1`.DataOffset {

    public enum Error: Swift.Error, Sendable, Equatable {
        case insufficientBytes
        case valueTooSmall
        case valueTooLarge
        case notAligned
    }
}

extension RFC_9293.`3`.`1`.DataOffset.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes:
            return "Data offset requires 1 byte"

        case .valueTooSmall:
            return "Data offset must be at least 5 (20 bytes)"

        case .valueTooLarge:
            return "Data offset cannot exceed 15 (60 bytes)"

        case .notAligned:
            return "Header length must be a multiple of 4 bytes"
        }
    }
}
