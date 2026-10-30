#if Coder
    import Byte
    import Coder
    import Cursor
    import Parser
    import RFC_9293
    import Serializer
    import Testing

    @Suite
    struct `RFC_9293.SequenceNumber.Coder Tests` {

        @Test
        func `reads four network-order octets and stops`() throws {
            var input = bytes(0x00, 0x01, 0x02, 0x03, 0xFF)[...]
            let sequenceNumber = try RFC_9293.SequenceNumber.coder.parse(&input)

            #expect(sequenceNumber.rawValue == 0x0001_0203)
            #expect(input == bytes(0xFF)[...])
        }

        @Test
        func `rejects fewer than four octets and restores the cursor`() {
            var input = bytes(0x00, 0x01, 0x02)[...]
            #expect(throws: RFC_9293.SequenceNumber.Error.insufficientBytes) {
                try RFC_9293.SequenceNumber.coder.parse(&input)
            }
            #expect(input.count == 3)
        }

        @Test
        func `a sequence number survives the round trip`() throws {
            let sequenceNumber = RFC_9293.SequenceNumber(rawValue: 0xDEAD_BEEF)
            var input = try RFC_9293.SequenceNumber.coder.serialize(sequenceNumber)[...]

            #expect(input == bytes(0xDE, 0xAD, 0xBE, 0xEF)[...])
            #expect(try RFC_9293.SequenceNumber.coder.parse(&input) == sequenceNumber)
        }
    }
#endif
