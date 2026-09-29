public import Byte

extension RFC_9293.`3`.`2` {

    public enum Option: Hashable, Sendable {

        case endOfOptionList

        case noOperation

        case maximumSegmentSize(UInt16)

        case windowScale(UInt8)

        case sackPermitted

        case sack([SACK.Block])

        case timestamps(value: UInt32, echoReply: UInt32)

        case unknown(kind: UInt8, data: [Byte])
    }
}

extension RFC_9293.`3`.`2` {

    public enum SACK {}
}

extension RFC_9293.`3`.`2`.SACK {

    public struct Block: Hashable, Sendable {

        public let leftEdge: RFC_9293.SequenceNumber

        public let rightEdge: RFC_9293.SequenceNumber

        public init(leftEdge: RFC_9293.SequenceNumber, rightEdge: RFC_9293.SequenceNumber) {
            self.leftEdge = leftEdge
            self.rightEdge = rightEdge
        }
    }
}

extension RFC_9293.`3`.`2`.Option {

    public enum Kind: UInt8, Hashable, Sendable {
        case endOfOptionList = 0
        case noOperation = 1
        case maximumSegmentSize = 2
        case windowScale = 3
        case sackPermitted = 4
        case sack = 5
        case timestamps = 8
    }
}

extension RFC_9293.`3`.`2`.Option {

    public var kind: UInt8 {
        switch self {
        case .endOfOptionList: return 0
        case .noOperation: return 1
        case .maximumSegmentSize: return 2
        case .windowScale: return 3
        case .sackPermitted: return 4
        case .sack: return 5
        case .timestamps: return 8
        case .unknown(let k, _): return k
        }
    }

    public var length: Int {
        switch self {
        case .endOfOptionList: return 1
        case .noOperation: return 1
        case .maximumSegmentSize: return 4
        case .windowScale: return 3
        case .sackPermitted: return 2
        case .sack(let blocks): return 2 + (blocks.count * 8)
        case .timestamps: return 10
        case .unknown(_, let data): return 2 + data.count
        }
    }
}

extension RFC_9293.`3`.`2`.Option: CustomStringConvertible {
    public var description: String {
        switch self {
        case .endOfOptionList:
            return "EOL"

        case .noOperation:
            return "NOP"

        case .maximumSegmentSize(let mss):
            return "MSS=\(mss)"

        case .windowScale(let shift):
            return "WS=\(shift)"

        case .sackPermitted:
            return "SACK-OK"

        case .sack(let blocks):
            let ranges = blocks.map { "\($0.leftEdge)-\($0.rightEdge)" }
            return "SACK[\(ranges.joined(separator: ","))]"

        case .timestamps(let value, let echo):
            return "TS=\(value)/\(echo)"

        case .unknown(let kind, _):
            return "OPT(\(kind))"
        }
    }
}
