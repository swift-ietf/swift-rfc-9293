import Byte
import RFC_9293
import Testing

@Suite
struct `RFC_9293.3.1.Header Tests` {

    @Test
    func `a header without options is five words long`() {
        let header = RFC_9293.`3`.`1`.Header(
            sourcePort: 8080,
            destinationPort: .http,
            sequenceNumber: .init(rawValue: 12345),
            acknowledgmentNumber: .init(rawValue: 0),
            flags: [.syn],
            window: 65535,
            checksum: 0,
            urgentPointer: 0
        )

        #expect(header.sourcePort.rawValue == 8080)
        #expect(header.destinationPort == .http)
        #expect(header.flags.contains(.syn))
        #expect(header.dataOffset == .minimum)
        #expect(header.options.isEmpty)
    }

    @Test
    func `a header carries its options beside the data offset that measures them`() throws {
        let header = RFC_9293.`3`.`1`.Header(
            sourcePort: 8080,
            destinationPort: .http,
            sequenceNumber: .init(rawValue: 12345),
            acknowledgmentNumber: .init(rawValue: 0),
            dataOffset: try .init(rawValue: 6),
            flags: [.syn],
            window: 65535,
            checksum: 0,
            urgentPointer: 0,
            options: [
                Byte(bitPattern: 0x02),
                Byte(bitPattern: 0x04),
                Byte(bitPattern: 0x05),
                Byte(bitPattern: 0xB4),
            ]
        )

        #expect(header.dataOffset.headerLength == 24)
        #expect(header.dataOffset.optionsLength == 4)
        #expect(header.options.count == 4)
    }

    @Test
    func `a header reads back as the connection it describes`() {
        let header = RFC_9293.`3`.`1`.Header(
            sourcePort: 12345,
            destinationPort: .https,
            sequenceNumber: .init(rawValue: 1000),
            acknowledgmentNumber: .init(rawValue: 2000),
            flags: .synAck,
            window: 32768,
            checksum: 0,
            urgentPointer: 0
        )

        #expect(header.description == "TCP 12345 → 443 [ACK|SYN] seq=1000 ack=2000 win=32768")
    }
}
