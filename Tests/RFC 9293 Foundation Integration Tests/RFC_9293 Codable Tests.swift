import Foundation
import RFC_9293
import RFC_9293_Foundation_Integration
import Testing

@Suite
struct `RFC_9293 Codable Tests` {

    @Test
    func `a port codes as its number`() throws {
        let port = RFC_9293.Port(8080)
        let encoded = try JSONEncoder().encode(port)

        #expect(String(decoding: encoded, as: UTF8.self) == "8080")
        #expect(try JSONDecoder().decode(RFC_9293.Port.self, from: encoded) == port)
    }

    @Test
    func `a sequence number codes as its number`() throws {
        let sequenceNumber = RFC_9293.SequenceNumber(rawValue: 4_294_967_295)
        let encoded = try JSONEncoder().encode(sequenceNumber)

        #expect(String(decoding: encoded, as: UTF8.self) == "4294967295")
        #expect(
            try JSONDecoder().decode(RFC_9293.SequenceNumber.self, from: encoded) == sequenceNumber
        )
    }

    @Test
    func `a data offset codes as its word count and stays validated`() throws {
        let offset = try RFC_9293.`3`.`1`.DataOffset(rawValue: 6)
        let encoded = try JSONEncoder().encode(offset)

        #expect(String(decoding: encoded, as: UTF8.self) == "6")
        #expect(
            try JSONDecoder().decode(RFC_9293.`3`.`1`.DataOffset.self, from: encoded) == offset
        )
        #expect(throws: RFC_9293.`3`.`1`.DataOffset.Error.valueTooSmall) {
            try JSONDecoder().decode(
                RFC_9293.`3`.`1`.DataOffset.self,
                from: Data("4".utf8)
            )
        }
    }

    @Test
    func `control flags code as one control field`() throws {
        let flags: RFC_9293.`3`.`1`.Flags = [.syn, .ack]
        let encoded = try JSONEncoder().encode(flags)

        #expect(String(decoding: encoded, as: UTF8.self) == "18")
        #expect(try JSONDecoder().decode(RFC_9293.`3`.`1`.Flags.self, from: encoded) == flags)
    }

    @Test
    func `a connection state codes as the name the specification uses`() throws {
        let state = RFC_9293.`3`.`3`.State.synSent
        let encoded = try JSONEncoder().encode(state)

        #expect(String(decoding: encoded, as: UTF8.self) == #""SYN-SENT""#)
        #expect(try JSONDecoder().decode(RFC_9293.`3`.`3`.State.self, from: encoded) == state)
    }

    @Test
    func `a selective acknowledgment block codes as its two edges`() throws {
        let block = RFC_9293.`3`.`2`.SACK.Block(
            leftEdge: .init(rawValue: 1000),
            rightEdge: .init(rawValue: 2000)
        )
        let encoded = try JSONEncoder().encode(block)

        #expect(
            try JSONDecoder().decode(RFC_9293.`3`.`2`.SACK.Block.self, from: encoded) == block
        )
    }
}
