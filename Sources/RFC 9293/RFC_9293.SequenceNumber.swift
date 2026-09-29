extension RFC_9293 {

    public struct SequenceNumber: RawRepresentable, Hashable, Sendable {
        public let rawValue: UInt32

        private init(__unchecked: Void, rawValue: UInt32) {
            self.rawValue = rawValue
        }

        public init(rawValue: UInt32) {
            self.init(__unchecked: (), rawValue: rawValue)
        }
    }
}

extension RFC_9293.SequenceNumber: Comparable {

    public static func < (lhs: Self, rhs: Self) -> Bool {
        Int32(bitPattern: lhs.rawValue &- rhs.rawValue) < 0
    }
}

extension RFC_9293.SequenceNumber {

    public static func + (lhs: Self, rhs: UInt32) -> Self {
        Self(rawValue: lhs.rawValue &+ rhs)
    }

    public static func += (lhs: inout Self, rhs: UInt32) {
        lhs = lhs + rhs
    }

    public static func - (lhs: Self, rhs: Self) -> UInt32 {
        lhs.rawValue &- rhs.rawValue
    }
}

extension RFC_9293.SequenceNumber {

    public func isWithin(left: Self, right: Self) -> Bool {
        left <= self && self <= right
    }

    public func isBetween(left: Self, right: Self) -> Bool {
        left < self && self < right
    }
}

extension RFC_9293.SequenceNumber: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}
