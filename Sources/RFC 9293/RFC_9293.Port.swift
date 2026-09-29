extension RFC_9293 {

    public struct Port: RawRepresentable, Hashable, Sendable {
        public let rawValue: UInt16

        private init(__unchecked: Void, rawValue: UInt16) {
            self.rawValue = rawValue
        }

        public init(rawValue: UInt16) {
            self.init(__unchecked: (), rawValue: rawValue)
        }

        public init(_ value: UInt16) {
            self.init(__unchecked: (), rawValue: value)
        }
    }
}

extension RFC_9293.Port {

    public static let ftpData = Self(__unchecked: (), rawValue: 20)

    public static let ftp = Self(__unchecked: (), rawValue: 21)

    public static let ssh = Self(__unchecked: (), rawValue: 22)

    public static let telnet = Self(__unchecked: (), rawValue: 23)

    public static let smtp = Self(__unchecked: (), rawValue: 25)

    public static let http = Self(__unchecked: (), rawValue: 80)

    public static let https = Self(__unchecked: (), rawValue: 443)
}

extension RFC_9293.Port {

    public var isWellKnown: Bool { rawValue < 1024 }

    public var isRegistered: Bool { rawValue >= 1024 && rawValue < 49152 }

    public var isDynamic: Bool { rawValue >= 49152 }
}

extension RFC_9293.Port: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt16) {
        self.init(value)
    }
}

extension RFC_9293.Port: CustomStringConvertible {
    public var description: String {
        String(rawValue)
    }
}
