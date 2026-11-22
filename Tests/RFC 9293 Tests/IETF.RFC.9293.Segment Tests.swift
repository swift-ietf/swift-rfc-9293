import Byte
import RFC_9293
import Testing

@Suite
struct `IETF.RFC.9293.Segment Tests` {

    private static func header(
        flags: IETF.RFC.`9293`.`3`.`1`.Flags,
        sequenceNumber: IETF.RFC.`9293`.SequenceNumber = .init(rawValue: 1000)
    ) -> IETF.RFC.`9293`.`3`.`1`.Header {
        IETF.RFC.`9293`.`3`.`1`.Header(
            sourcePort: 8080,
            destinationPort: .http,
            sequenceNumber: sequenceNumber,
            acknowledgmentNumber: .init(rawValue: 0),
            flags: flags,
            window: 65535,
            checksum: 0,
            urgentPointer: 0
        )
    }

    @Test
    func `a segment is its header plus the data it carries`() {
        let segment = IETF.RFC.`9293`.Segment(
            header: Self.header(flags: []),
            data: [Byte(bitPattern: 0x41), Byte(bitPattern: 0x42)]
        )

        #expect(segment.length == 22)
        #expect(segment.sequenceNumber == .init(rawValue: 1000))
    }

    @Test
    func `a segment with no data occupies only its header`() {
        let segment = IETF.RFC.`9293`.Segment(header: Self.header(flags: [.ack]))

        #expect(segment.data.isEmpty)
        #expect(segment.length == 20)
        #expect(segment.segmentLength == 0)
    }

    @Test
    func `the synchronize and finish flags each consume one sequence number`() {
        let synchronize = IETF.RFC.`9293`.Segment(header: Self.header(flags: [.syn]))
        #expect(synchronize.segmentLength == 1)
        #expect(synchronize.nextSequenceNumber == .init(rawValue: 1001))

        let finish = IETF.RFC.`9293`.Segment(
            header: Self.header(flags: [.fin]),
            data: [Byte(bitPattern: 0x41)]
        )
        #expect(finish.segmentLength == 2)
        #expect(finish.nextSequenceNumber == .init(rawValue: 1002))
    }
}
