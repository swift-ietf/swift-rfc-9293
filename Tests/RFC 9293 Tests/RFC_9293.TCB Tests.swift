import RFC_791
import RFC_791_Standard_Library_Integration
import RFC_9293
import Testing

@Suite
struct `RFC_9293.TCB Tests` {

    @Test
    func `a socket pairs an address with a port`() {
        let socket = RFC_9293.TCB.Socket(
            address: RFC_791.IPv4.Address(192, 168, 1, 1),
            port: 8080
        )

        #expect(socket.port.rawValue == 8080)
        #expect(socket.description == "192.168.1.1:8080")
    }

    @Test
    func `a control block reports what its state allows`() {
        let block = RFC_9293.TCB(
            local: .init(address: RFC_791.IPv4.Address(192, 168, 1, 1), port: 8080),
            remote: .init(address: RFC_791.IPv4.Address(192, 168, 1, 2), port: .http),
            state: .established,
            send: .init(iss: .init(rawValue: 1000)),
            receive: nil
        )

        #expect(block.isSynchronized)
        #expect(block.canSend)
        #expect(block.canReceive)
    }

    @Test
    func `the effective maximum segment size is the smaller of the two`() {
        let block = RFC_9293.TCB(
            local: .init(address: RFC_791.IPv4.Address(10, 0, 0, 1), port: 8080),
            remote: .init(address: RFC_791.IPv4.Address(10, 0, 0, 2), port: .https),
            state: .established,
            send: .init(iss: .init(rawValue: 1)),
            receive: nil,
            sendMSS: 1460,
            receiveMSS: 536
        )

        #expect(block.effectiveMSS == 536)
        #expect(block.connectionTuple.local == block.local)
    }
}
