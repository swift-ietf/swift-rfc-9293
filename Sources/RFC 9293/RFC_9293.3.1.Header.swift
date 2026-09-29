public import Byte

extension RFC_9293.`3`.`1` {

    public struct Header: Hashable, Sendable {

        public let sourcePort: RFC_9293.Port

        public let destinationPort: RFC_9293.Port

        public let sequenceNumber: RFC_9293.SequenceNumber

        public let acknowledgmentNumber: RFC_9293.SequenceNumber

        public let dataOffset: DataOffset

        public let flags: Flags

        public let window: UInt16

        public let checksum: UInt16

        public let urgentPointer: UInt16

        public let options: [Byte]

        private init(
            __unchecked: Void,
            sourcePort: RFC_9293.Port,
            destinationPort: RFC_9293.Port,
            sequenceNumber: RFC_9293.SequenceNumber,
            acknowledgmentNumber: RFC_9293.SequenceNumber,
            dataOffset: DataOffset,
            flags: Flags,
            window: UInt16,
            checksum: UInt16,
            urgentPointer: UInt16,
            options: [Byte]
        ) {
            self.sourcePort = sourcePort
            self.destinationPort = destinationPort
            self.sequenceNumber = sequenceNumber
            self.acknowledgmentNumber = acknowledgmentNumber
            self.dataOffset = dataOffset
            self.flags = flags
            self.window = window
            self.checksum = checksum
            self.urgentPointer = urgentPointer
            self.options = options
        }

        public init(
            sourcePort: RFC_9293.Port,
            destinationPort: RFC_9293.Port,
            sequenceNumber: RFC_9293.SequenceNumber,
            acknowledgmentNumber: RFC_9293.SequenceNumber,
            dataOffset: DataOffset,
            flags: Flags,
            window: UInt16,
            checksum: UInt16,
            urgentPointer: UInt16,
            options: [Byte]
        ) {
            self.init(
                __unchecked: (),
                sourcePort: sourcePort,
                destinationPort: destinationPort,
                sequenceNumber: sequenceNumber,
                acknowledgmentNumber: acknowledgmentNumber,
                dataOffset: dataOffset,
                flags: flags,
                window: window,
                checksum: checksum,
                urgentPointer: urgentPointer,
                options: options
            )
        }

    }
}

extension RFC_9293.`3`.`1`.Header {

    public init(
        sourcePort: RFC_9293.Port,
        destinationPort: RFC_9293.Port,
        sequenceNumber: RFC_9293.SequenceNumber,
        acknowledgmentNumber: RFC_9293.SequenceNumber,
        flags: RFC_9293.`3`.`1`.Flags,
        window: UInt16,
        checksum: UInt16,
        urgentPointer: UInt16
    ) {
        self.init(
            __unchecked: (),
            sourcePort: sourcePort,
            destinationPort: destinationPort,
            sequenceNumber: sequenceNumber,
            acknowledgmentNumber: acknowledgmentNumber,
            dataOffset: .minimum,
            flags: flags,
            window: window,
            checksum: checksum,
            urgentPointer: urgentPointer,
            options: []
        )
    }
}

extension RFC_9293.`3`.`1`.Header: CustomStringConvertible {
    public var description: String {
        "TCP \(sourcePort) → \(destinationPort) [\(flags)] seq=\(sequenceNumber) ack=\(acknowledgmentNumber) win=\(window)"
    }
}
