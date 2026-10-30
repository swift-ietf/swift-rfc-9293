#if Coder
    import Byte
    import Coder
    import Cursor
    import Parser
    import RFC_9293
    import Serializer
    import Testing

    @Suite
    struct `RFC_9293.3.1.Flags.Coder Tests` {

        @Test
        func `reads the control field from one octet`() throws {
            var input = bytes(0x12)[...]
            #expect(try RFC_9293.`3`.`1`.Flags.coder.parse(&input) == .synAck)
        }

        @Test
        func `writes the control field as one octet`() throws {
            #expect(try RFC_9293.`3`.`1`.Flags.coder.serialize(.synAck) == bytes(0x12))
            #expect(try RFC_9293.`3`.`1`.Flags.coder.serialize(.none) == bytes(0x00))
        }

        @Test
        func `rejects empty input`() {
            var input = bytes()[...]
            #expect(throws: RFC_9293.`3`.`1`.Flags.Error.insufficientBytes) {
                try RFC_9293.`3`.`1`.Flags.coder.parse(&input)
            }
        }
    }
#endif
