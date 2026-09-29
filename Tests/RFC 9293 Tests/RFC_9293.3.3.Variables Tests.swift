import RFC_9293
import Testing

@Suite
struct `RFC_9293.3.3 Sequence Variables Tests` {

    @Test
    func `send variables start one past the initial send sequence`() {
        let send = RFC_9293.`3`.`3`.Send.Variables(iss: .init(rawValue: 1000))

        #expect(send.una == .init(rawValue: 1000))
        #expect(send.nxt == .init(rawValue: 1001))
        #expect(send.flightSize == 1)
        #expect(send.description == "SND(UNA=1000 NXT=1001 WND=0 ISS=1000)")
    }

    @Test
    func `the usable send window is what the window leaves unsent`() {
        var send = RFC_9293.`3`.`3`.Send.Variables(iss: .init(rawValue: 1000))
        send.wnd = 100

        #expect(send.windowEnd == .init(rawValue: 1100))
        #expect(send.usableWindow == 99)
        #expect(!send.isWindowFull)
    }

    @Test
    func `receive variables start one past the initial receive sequence`() {
        let receive = RFC_9293.`3`.`3`.Receive.Variables(
            irs: .init(rawValue: 500),
            windowSize: 100
        )

        #expect(receive.nxt == .init(rawValue: 501))
        #expect(receive.windowEnd == .init(rawValue: 601))
        #expect(receive.isInWindow(.init(rawValue: 550)))
        #expect(!receive.isInWindow(.init(rawValue: 700)))
        #expect(receive.description == "RCV(NXT=501 WND=100 IRS=500)")
    }
}
