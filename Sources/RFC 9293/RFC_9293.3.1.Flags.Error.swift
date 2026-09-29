extension RFC_9293.`3`.`1`.Flags {

    public enum Error: Swift.Error, Sendable, Equatable {
        case insufficientBytes
    }
}

extension RFC_9293.`3`.`1`.Flags.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes:
            return "Control flags require 1 byte"
        }
    }
}
