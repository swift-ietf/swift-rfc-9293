public import RFC_791

extension IETF.RFC.`9293` {

    public struct TCB: Sendable {

        public let local: Socket

        public let remote: Socket

        public var state: `3`.`3`.State

        public var send: `3`.`3`.Send.Variables

        public var receive: `3`.`3`.Receive.Variables?

        public var sendMSS: UInt16

        public var receiveMSS: UInt16

        public init(
            local: Socket,
            remote: Socket,
            state: `3`.`3`.State,
            send: `3`.`3`.Send.Variables,
            receive: `3`.`3`.Receive.Variables?,
            sendMSS: UInt16 = IETF.RFC.`9293`.defaultMSSIPv4,
            receiveMSS: UInt16 = IETF.RFC.`9293`.defaultMSSIPv4
        ) {
            self.local = local
            self.remote = remote
            self.state = state
            self.send = send
            self.receive = receive
            self.sendMSS = sendMSS
            self.receiveMSS = receiveMSS
        }
    }
}

extension IETF.RFC.`9293`.TCB {

    public struct Socket: Hashable, Sendable {

        public let address: IETF.RFC.`791`.IPv4.Address

        public let port: IETF.RFC.`9293`.Port

        public init(address: IETF.RFC.`791`.IPv4.Address, port: IETF.RFC.`9293`.Port) {
            self.address = address
            self.port = port
        }
    }
}

extension IETF.RFC.`9293`.TCB {

    public var connectionTuple: Connection {
        Connection(local: local, remote: remote)
    }
}

extension IETF.RFC.`9293`.TCB {

    public struct Connection: Hashable, Sendable {
        public let local: Socket
        public let remote: Socket

        public init(local: Socket, remote: Socket) {
            self.local = local
            self.remote = remote
        }
    }
}

extension IETF.RFC.`9293`.TCB {

    public var isSynchronized: Bool {
        state.isSynchronized
    }

    public var canSend: Bool {
        state.canSendData
    }

    public var canReceive: Bool {
        state.canReceiveData
    }

    public var effectiveMSS: UInt16 {
        min(sendMSS, receiveMSS)
    }
}

extension IETF.RFC.`9293`.TCB: CustomStringConvertible {
    public var description: String {
        "TCB[\(state)] \(local.port)→\(remote.port) \(send) \(receive?.description ?? "RCV(--)")"
    }
}

extension IETF.RFC.`9293`.TCB.Socket: CustomStringConvertible {
    public var description: String {
        "\(address):\(port)"
    }
}
