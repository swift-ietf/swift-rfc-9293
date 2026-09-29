import Byte
import RFC_9293
import RFC_9293_Standard_Library_Integration
import Testing

@Suite
struct `RFC_9293 UInt8 Forwarder Tests` {

    @Test
    func `a segment accepts its data as unsigned bytes`() {
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

        let data: [UInt8] = Array("Hello".utf8)
        let segment = RFC_9293.Segment(header: header, data: data)

        #expect(segment.data.count == 5)
        #expect(segment.data == data.map(Byte.init(bitPattern:)))
    }

    @Test
    func `a header accepts its options as unsigned bytes`() throws {
        let options: [UInt8] = [0x02, 0x04, 0x05, 0xB4]
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
            options: options
        )

        #expect(header.options.count == 4)
        #expect(header.options == options.map(Byte.init(bitPattern:)))
    }
}
