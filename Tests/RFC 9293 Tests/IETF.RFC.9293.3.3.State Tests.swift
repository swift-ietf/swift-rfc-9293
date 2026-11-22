import RFC_9293
import Testing

@Suite
struct `IETF.RFC.9293.3.3.State Tests` {

    @Test
    func `each connection state spells its name as the specification does`() {
        #expect(IETF.RFC.`9293`.`3`.`3`.State.closed.rawValue == "CLOSED")
        #expect(IETF.RFC.`9293`.`3`.`3`.State.established.rawValue == "ESTABLISHED")
        #expect(IETF.RFC.`9293`.`3`.`3`.State.synSent.rawValue == "SYN-SENT")
    }

    @Test
    func `data may be sent only once the connection is open at this end`() {
        #expect(IETF.RFC.`9293`.`3`.`3`.State.established.canSendData)
        #expect(IETF.RFC.`9293`.`3`.`3`.State.closeWait.canSendData)
        #expect(!IETF.RFC.`9293`.`3`.`3`.State.closed.canSendData)
        #expect(!IETF.RFC.`9293`.`3`.`3`.State.listen.canSendData)
    }

    @Test
    func `data may be received until the far end has finished sending`() {
        #expect(IETF.RFC.`9293`.`3`.`3`.State.established.canReceiveData)
        #expect(IETF.RFC.`9293`.`3`.`3`.State.finWait1.canReceiveData)
        #expect(IETF.RFC.`9293`.`3`.`3`.State.finWait2.canReceiveData)
        #expect(!IETF.RFC.`9293`.`3`.`3`.State.closed.canReceiveData)
    }

    @Test
    func `a synchronized state is one where both sequence spaces are established`() {
        #expect(IETF.RFC.`9293`.`3`.`3`.State.established.isSynchronized)
        #expect(IETF.RFC.`9293`.`3`.`3`.State.finWait1.isSynchronized)
        #expect(!IETF.RFC.`9293`.`3`.`3`.State.closed.isSynchronized)
        #expect(!IETF.RFC.`9293`.`3`.`3`.State.synSent.isSynchronized)
    }

    @Test
    func `a closing state is one the connection passes through on the way down`() {
        #expect(IETF.RFC.`9293`.`3`.`3`.State.finWait1.isClosing)
        #expect(IETF.RFC.`9293`.`3`.`3`.State.finWait2.isClosing)
        #expect(IETF.RFC.`9293`.`3`.`3`.State.timeWait.isClosing)
        #expect(!IETF.RFC.`9293`.`3`.`3`.State.established.isClosing)
    }
}
