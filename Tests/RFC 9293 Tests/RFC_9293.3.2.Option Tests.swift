import Byte
import RFC_9293
import Testing

@Suite
struct `RFC_9293.3.2.Option Tests` {

    @Test
    func `each option knows the kind number that introduces it`() {
        #expect(RFC_9293.`3`.`2`.Option.endOfOptionList.kind == 0)
        #expect(RFC_9293.`3`.`2`.Option.noOperation.kind == 1)
        #expect(RFC_9293.`3`.`2`.Option.maximumSegmentSize(1460).kind == 2)
        #expect(RFC_9293.`3`.`2`.Option.windowScale(7).kind == 3)
        #expect(RFC_9293.`3`.`2`.Option.sackPermitted.kind == 4)
        #expect(RFC_9293.`3`.`2`.Option.timestamps(value: 1, echoReply: 2).kind == 8)
    }

    @Test
    func `each option knows how many octets it occupies`() {
        #expect(RFC_9293.`3`.`2`.Option.endOfOptionList.length == 1)
        #expect(RFC_9293.`3`.`2`.Option.noOperation.length == 1)
        #expect(RFC_9293.`3`.`2`.Option.maximumSegmentSize(1460).length == 4)
        #expect(RFC_9293.`3`.`2`.Option.windowScale(7).length == 3)
        #expect(RFC_9293.`3`.`2`.Option.sackPermitted.length == 2)
        #expect(RFC_9293.`3`.`2`.Option.timestamps(value: 1, echoReply: 2).length == 10)
    }

    @Test
    func `a selective acknowledgment grows by eight octets for every block`() {
        let block = RFC_9293.`3`.`2`.SACK.Block(
            leftEdge: .init(rawValue: 1000),
            rightEdge: .init(rawValue: 2000)
        )

        #expect(RFC_9293.`3`.`2`.Option.sack([]).length == 2)
        #expect(RFC_9293.`3`.`2`.Option.sack([block]).length == 10)
        #expect(RFC_9293.`3`.`2`.Option.sack([block, block]).length == 18)
    }

    @Test
    func `an unrecognized option keeps its kind and its payload`() {
        let option = RFC_9293.`3`.`2`.Option.unknown(
            kind: 99,
            data: [Byte(bitPattern: 0xAA), Byte(bitPattern: 0xBB)]
        )

        #expect(option.kind == 99)
        #expect(option.length == 4)
        #expect(option.description == "OPT(99)")
    }
}
