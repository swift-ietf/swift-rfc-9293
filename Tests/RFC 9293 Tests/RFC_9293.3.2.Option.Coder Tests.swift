#if Coder
    import Byte
    import Coder
    import Cursor
    import Parser
    import RFC_9293
    import Serializer
    import Testing

    @Suite
    struct `RFC_9293.3.2.Option.Coder Tests` {

        @Test
        func `a maximum segment size option is four octets`() throws {
            let option = RFC_9293.`3`.`2`.Option.maximumSegmentSize(1460)
            var input = try RFC_9293.`3`.`2`.Option.coder.serialize(option)[...]

            #expect(input == bytes(0x02, 0x04, 0x05, 0xB4)[...])
            #expect(try RFC_9293.`3`.`2`.Option.coder.parse(&input) == option)
            #expect(input.isEmpty)
        }

        @Test
        func `the single-octet options carry no length`() throws {
            #expect(try RFC_9293.`3`.`2`.Option.coder.serialize(.endOfOptionList) == bytes(0x00))
            #expect(try RFC_9293.`3`.`2`.Option.coder.serialize(.noOperation) == bytes(0x01))

            var input = bytes(0x01, 0x00)[...]
            #expect(try RFC_9293.`3`.`2`.Option.coder.parse(&input) == .noOperation)
            #expect(try RFC_9293.`3`.`2`.Option.coder.parse(&input) == .endOfOptionList)
            #expect(input.isEmpty)
        }

        @Test
        func `a window scale option survives the round trip`() throws {
            let option = RFC_9293.`3`.`2`.Option.windowScale(7)
            var input = try RFC_9293.`3`.`2`.Option.coder.serialize(option)[...]

            #expect(input == bytes(0x03, 0x03, 0x07)[...])
            #expect(try RFC_9293.`3`.`2`.Option.coder.parse(&input) == option)
        }

        @Test
        func `a timestamps option survives the round trip`() throws {
            let option = RFC_9293.`3`.`2`.Option.timestamps(value: 12345, echoReply: 67890)
            var input = try RFC_9293.`3`.`2`.Option.coder.serialize(option)[...]

            #expect(input.count == 10)
            #expect(try RFC_9293.`3`.`2`.Option.coder.parse(&input) == option)
        }

        @Test
        func `a selective acknowledgment option survives the round trip`() throws {
            let option = RFC_9293.`3`.`2`.Option.sack([
                .init(leftEdge: .init(rawValue: 1000), rightEdge: .init(rawValue: 2000))
            ])
            var input = try RFC_9293.`3`.`2`.Option.coder.serialize(option)[...]

            #expect(input.count == 10)
            #expect(try RFC_9293.`3`.`2`.Option.coder.parse(&input) == option)
        }

        @Test
        func `an unrecognized option keeps its kind and payload`() throws {
            let option = RFC_9293.`3`.`2`.Option.unknown(kind: 99, data: bytes(0xAA, 0xBB))
            var input = try RFC_9293.`3`.`2`.Option.coder.serialize(option)[...]

            #expect(input == bytes(0x63, 0x04, 0xAA, 0xBB)[...])
            #expect(try RFC_9293.`3`.`2`.Option.coder.parse(&input) == option)
        }

        @Test
        func `an option whose declared length is wrong is rejected and the cursor restored`() {
            var input = bytes(0x02, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00)[...]
            #expect(throws: RFC_9293.`3`.`2`.Option.Error.invalidLength) {
                try RFC_9293.`3`.`2`.Option.coder.parse(&input)
            }
            #expect(input.count == 8)
        }

        @Test
        func `an option that runs out of octets is rejected and the cursor restored`() {
            var input = bytes(0x02, 0x04, 0x05)[...]
            #expect(throws: RFC_9293.`3`.`2`.Option.Error.insufficientBytes) {
                try RFC_9293.`3`.`2`.Option.coder.parse(&input)
            }
            #expect(input.count == 3)
        }
    }
#endif
