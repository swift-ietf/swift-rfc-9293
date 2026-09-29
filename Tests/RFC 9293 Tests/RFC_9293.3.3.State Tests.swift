import RFC_9293
import Testing

@Suite
struct `RFC_9293.3.3.State Tests` {

    @Test
    func `each connection state spells its name as the specification does`() {
        #expect(RFC_9293.`3`.`3`.State.closed.rawValue == "CLOSED")
        #expect(RFC_9293.`3`.`3`.State.established.rawValue == "ESTABLISHED")
        #expect(RFC_9293.`3`.`3`.State.synSent.rawValue == "SYN-SENT")
    }

    @Test
    func `data may be sent only once the connection is open at this end`() {
        #expect(RFC_9293.`3`.`3`.State.established.canSendData)
        #expect(RFC_9293.`3`.`3`.State.closeWait.canSendData)
        #expect(!RFC_9293.`3`.`3`.State.closed.canSendData)
        #expect(!RFC_9293.`3`.`3`.State.listen.canSendData)
    }

    @Test
    func `data may be received until the far end has finished sending`() {
        #expect(RFC_9293.`3`.`3`.State.established.canReceiveData)
        #expect(RFC_9293.`3`.`3`.State.finWait1.canReceiveData)
        #expect(RFC_9293.`3`.`3`.State.finWait2.canReceiveData)
        #expect(!RFC_9293.`3`.`3`.State.closed.canReceiveData)
    }

    @Test
    func `a synchronized state is one where both sequence spaces are established`() {
        #expect(RFC_9293.`3`.`3`.State.established.isSynchronized)
        #expect(RFC_9293.`3`.`3`.State.finWait1.isSynchronized)
        #expect(!RFC_9293.`3`.`3`.State.closed.isSynchronized)
        #expect(!RFC_9293.`3`.`3`.State.synSent.isSynchronized)
    }

    @Test
    func `a closing state is one the connection passes through on the way down`() {
        #expect(RFC_9293.`3`.`3`.State.finWait1.isClosing)
        #expect(RFC_9293.`3`.`3`.State.finWait2.isClosing)
        #expect(RFC_9293.`3`.`3`.State.timeWait.isClosing)
        #expect(!RFC_9293.`3`.`3`.State.established.isClosing)
    }
}
