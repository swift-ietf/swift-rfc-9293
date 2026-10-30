#if Coder
    import Byte
    import Coder
    import Cursor
    import Parser
    import RFC_9293
    import Serializer
    import Testing

    @Suite
    struct `RFC_9293.3.1.Header.Coder Tests` {

        @Test
        func `reads the twenty octets of a header without options`() throws {
            var input = bytes(
                0x1F,
                0x90,
                0x00,
                0x50,
                0x00,
                0x00,
                0x30,
                0x39,
                0x00,
                0x00,
                0x00,
                0x00,
                0x50,
                0x02,
                0xFF,
                0xFF,
                0x00,
                0x00,
                0x00,
                0x00
            )[...]

            let header = try RFC_9293.`3`.`1`.Header.coder.parse(&input)

            #expect(header.sourcePort == 8080)
            #expect(header.destinationPort == .http)
            #expect(header.sequenceNumber == .init(rawValue: 12345))
            #expect(header.acknowledgmentNumber == .init(rawValue: 0))
            #expect(header.flags == [.syn])
            #expect(header.window == 65535)
            #expect(header.options.isEmpty)
            #expect(input.isEmpty)
        }

        @Test
        func `reads the options the data offset announces`() throws {
            var input = bytes(
                0x1F,
                0x90,
                0x00,
                0x50,
                0x00,
                0x00,
                0x30,
                0x39,
                0x00,
                0x00,
                0x00,
                0x00,
                0x60,
                0x02,
                0xFF,
                0xFF,
                0x00,
                0x00,
                0x00,
                0x00,
                0x02,
                0x04,
                0x05,
                0xB4
            )[...]

            let header = try RFC_9293.`3`.`1`.Header.coder.parse(&input)

            #expect(header.dataOffset.headerLength == 24)
            #expect(header.options == bytes(0x02, 0x04, 0x05, 0xB4))
            #expect(input.isEmpty)
        }

        @Test
        func `rejects a header shorter than twenty octets and restores the cursor`() {
            var input = bytes(0x1F, 0x90, 0x00, 0x50)[...]
            #expect(throws: RFC_9293.`3`.`1`.Header.Error.insufficientBytes) {
                try RFC_9293.`3`.`1`.Header.coder.parse(&input)
            }
            #expect(input.count == 4)
        }

        @Test
        func `rejects a data offset below five and restores the cursor`() {
            var input = bytes(
                0x1F,
                0x90,
                0x00,
                0x50,
                0x00,
                0x00,
                0x30,
                0x39,
                0x00,
                0x00,
                0x00,
                0x00,
                0x40,
                0x02,
                0xFF,
                0xFF,
                0x00,
                0x00,
                0x00,
                0x00
            )[...]

            #expect(throws: RFC_9293.`3`.`1`.Header.Error.dataOffsetTooSmall) {
                try RFC_9293.`3`.`1`.Header.coder.parse(&input)
            }
            #expect(input.count == 20)
        }

        @Test
        func `a header survives the round trip`() throws {
            let header = RFC_9293.`3`.`1`.Header(
                sourcePort: 12345,
                destinationPort: .https,
                sequenceNumber: .init(rawValue: 999_999),
                acknowledgmentNumber: .init(rawValue: 888_888),
                flags: .synAck,
                window: 32768,
                checksum: 0xABCD,
                urgentPointer: 0
            )

            var input = try RFC_9293.`3`.`1`.Header.coder.serialize(header)[...]

            #expect(input.count == 20)
            #expect(try RFC_9293.`3`.`1`.Header.coder.parse(&input) == header)
        }
    }
#endif
