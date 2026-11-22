import Byte
public import RFC_9293

extension IETF.RFC.`9293`.`3`.`1`.Header {

    @_disfavoredOverload
    public init(
        sourcePort: IETF.RFC.`9293`.Port,
        destinationPort: IETF.RFC.`9293`.Port,
        sequenceNumber: IETF.RFC.`9293`.SequenceNumber,
        acknowledgmentNumber: IETF.RFC.`9293`.SequenceNumber,
        flags: IETF.RFC.`9293`.`3`.`1`.Flags,
        window: UInt16,
        checksum: UInt16,
        urgentPointer: UInt16,
        options: [UInt8]
    ) throws(Error) {
        let bytes = [Byte](options.lazy.map(Byte.init(bitPattern:)))
        try self.init(
            sourcePort: sourcePort,
            destinationPort: destinationPort,
            sequenceNumber: sequenceNumber,
            acknowledgmentNumber: acknowledgmentNumber,
            flags: flags,
            window: window,
            checksum: checksum,
            urgentPointer: urgentPointer,
            options: bytes
        )
    }
}
