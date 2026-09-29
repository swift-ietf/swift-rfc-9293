import RFC_9293
import Testing

@Suite
struct `RFC_9293.3.1.Flags Tests` {

    @Test
    func `each control flag names one bit of the control field`() {
        #expect(RFC_9293.`3`.`1`.Flags.fin.rawValue == 0x01)
        #expect(RFC_9293.`3`.`1`.Flags.syn.rawValue == 0x02)
        #expect(RFC_9293.`3`.`1`.Flags.rst.rawValue == 0x04)
        #expect(RFC_9293.`3`.`1`.Flags.psh.rawValue == 0x08)
        #expect(RFC_9293.`3`.`1`.Flags.ack.rawValue == 0x10)
        #expect(RFC_9293.`3`.`1`.Flags.urg.rawValue == 0x20)
        #expect(RFC_9293.`3`.`1`.Flags.ece.rawValue == 0x40)
        #expect(RFC_9293.`3`.`1`.Flags.cwr.rawValue == 0x80)
    }

    @Test
    func `flags combine into one control field`() {
        let synAck: RFC_9293.`3`.`1`.Flags = [.syn, .ack]
        #expect(synAck.contains(.syn))
        #expect(synAck.contains(.ack))
        #expect(!synAck.contains(.fin))
        #expect(synAck.rawValue == 0x12)
    }

    @Test
    func `the handshake combinations are named`() {
        #expect(RFC_9293.`3`.`1`.Flags.synAck == [.syn, .ack])
        #expect(RFC_9293.`3`.`1`.Flags.finAck == [.fin, .ack])
        #expect(RFC_9293.`3`.`1`.Flags.none.isEmpty)
    }

    @Test
    func `flags read back in header order`() {
        let flags: RFC_9293.`3`.`1`.Flags = [.syn, .ack]
        #expect(flags.description == "ACK|SYN")
        #expect(RFC_9293.`3`.`1`.Flags.none.description == "none")
    }
}
