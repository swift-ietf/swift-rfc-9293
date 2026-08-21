extension RFC_9293 {

    public static let protocolNumber: UInt8 = 6

    public static let minimumHeaderSize: Int = 20

    public static let maximumHeaderSize: Int = 60

    public static let mslSeconds: UInt32 = 120

    public static let timeWaitDurationSeconds: UInt32 = 2 * mslSeconds

    public static let defaultMSSIPv4: UInt16 = 536

    public static let defaultMSSIPv6: UInt16 = 1220
}
