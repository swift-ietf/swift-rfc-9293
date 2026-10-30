#if Coder
    import Byte
    import Coder
    import Cursor
    import Parser
    import RFC_9293
    import Serializer
    import Testing

    @Suite
    struct `RFC_9293.Port.Coder Tests` {

        @Test
        func `reads two network-order octets and stops`() throws {
            var input = bytes(0x1F, 0x90, 0xFF)[...]
            let port = try RFC_9293.Port.coder.parse(&input)

            #expect(port == 8080)
            #expect(input == bytes(0xFF)[...])
        }

        @Test
        func `rejects empty input`() {
            var input = bytes()[...]
            #expect(throws: RFC_9293.Port.Error.empty) {
                try RFC_9293.Port.coder.parse(&input)
            }
        }

        @Test
        func `rejects a single octet and restores the cursor`() {
            var input = bytes(0x1F)[...]
            #expect(throws: RFC_9293.Port.Error.insufficientBytes) {
                try RFC_9293.Port.coder.parse(&input)
            }
            #expect(input.count == 1)
        }

        @Test
        func `writes two network-order octets`() throws {
            #expect(try RFC_9293.Port.coder.serialize(RFC_9293.Port(8080)) == bytes(0x1F, 0x90))
            #expect(try RFC_9293.Port.coder.serialize(.https) == bytes(0x01, 0xBB))
        }
    }
#endif
