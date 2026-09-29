public import Byte

extension RFC_9293 {

    public struct Segment: Hashable, Sendable {

        public let header: `3`.`1`.Header

        public let data: [Byte]

        private init(__unchecked: Void, header: `3`.`1`.Header, data: [Byte]) {
            self.header = header
            self.data = data
        }

        public init(header: `3`.`1`.Header, data: [Byte]) {
            self.init(__unchecked: (), header: header, data: data)
        }

    }
}

extension RFC_9293.Segment {

    public init(header: RFC_9293.`3`.`1`.Header) {
        self.init(__unchecked: (), header: header, data: [])
    }
}

extension RFC_9293.Segment {

    public var length: Int {
        header.dataOffset.headerLength + data.count
    }

    public var sequenceNumber: RFC_9293.SequenceNumber {
        header.sequenceNumber
    }

    public var nextSequenceNumber: RFC_9293.SequenceNumber {
        var seq = header.sequenceNumber + UInt32(data.count)

        if header.flags.contains(.syn) { seq += 1 }
        if header.flags.contains(.fin) { seq += 1 }

        return seq
    }

    public var segmentLength: UInt32 {
        var len = UInt32(data.count)
        if header.flags.contains(.syn) { len += 1 }
        if header.flags.contains(.fin) { len += 1 }
        return len
    }
}

extension RFC_9293.Segment: CustomStringConvertible {
    public var description: String {
        "\(header) len=\(data.count)"
    }
}
