#if Coder
    import Byte
    import Coder
    import Cursor
    import Parser
    import RFC_9293
    import Serializer
    import Testing

    @Suite
    struct `RFC_9293.Segment.Coder Tests` {

        @Test
        func `a segment is its header followed by its data`() throws {
            let segment = RFC_9293.Segment(
                header: RFC_9293.`3`.`1`.Header(
                    sourcePort: 8080,
                    destinationPort: .http,
                    sequenceNumber: .init(rawValue: 1000),
                    acknowledgmentNumber: .init(rawValue: 0),
                    flags: [.psh, .ack],
                    window: 65535,
                    checksum: 0,
                    urgentPointer: 0
                ),
                data: bytes(0x48, 0x69)
            )

            var input = try RFC_9293.Segment.coder.serialize(segment)[...]

            #expect(input.count == 22)
            #expect(try RFC_9293.Segment.coder.parse(&input) == segment)
            #expect(input.isEmpty)
        }

        @Test
        func `a segment shorter than a header is rejected and the cursor restored`() {
            var input = bytes(0x1F, 0x90)[...]
            #expect(throws: RFC_9293.Segment.Error.insufficientBytes) {
                try RFC_9293.Segment.coder.parse(&input)
            }
            #expect(input.count == 2)
        }

        @Test
        func `a segment whose header claims too few words is rejected`() {
            var input = bytes(
                0x1F,
                0x90,
                0x00,
                0x50,
                0x00,
                0x00,
                0x00,
                0x00,
                0x00,
                0x00,
                0x00,
                0x00,
                0x40,
                0x10,
                0xFF,
                0xFF,
                0x00,
                0x00,
                0x00,
                0x00
            )[...]

            #expect(throws: RFC_9293.Segment.Error.invalidDataOffset) {
                try RFC_9293.Segment.coder.parse(&input)
            }
            #expect(input.count == 20)
        }
    }
#endif
