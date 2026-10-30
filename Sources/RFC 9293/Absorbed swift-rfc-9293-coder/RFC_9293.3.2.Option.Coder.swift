#if Coder
    import Binary
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension RFC_9293.`3`.`2`.Option {

        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

            public typealias Output = RFC_9293.`3`.`2`.Option

            public typealias Failure = RFC_9293.`3`.`2`.Option.Error

            public init() {}

            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let start = input.checkpoint

                func octet() throws(Failure) -> UInt8 {
                    guard let byte = input.next() else {
                        input.seek(to: start)
                        throw .insufficientBytes
                    }
                    return byte.bitPattern
                }

                func sixteen() throws(Failure) -> UInt16 {
                    let high = try octet()
                    let low = try octet()
                    return UInt16(high) << 8 | UInt16(low)
                }

                func thirtyTwo() throws(Failure) -> UInt32 {
                    let high = try sixteen()
                    let low = try sixteen()
                    return UInt32(high) << 16 | UInt32(low)
                }

                func expect(length: UInt8) throws(Failure) {
                    guard try octet() == length else {
                        input.seek(to: start)
                        throw .invalidLength
                    }
                }

                switch try octet() {
                case 0:
                    return .endOfOptionList

                case 1:
                    return .noOperation

                case 2:
                    try expect(length: 4)
                    return .maximumSegmentSize(try sixteen())

                case 3:
                    try expect(length: 3)
                    return .windowScale(try octet())

                case 4:
                    try expect(length: 2)
                    return .sackPermitted

                case 5:
                    let length = Int(try octet()) - 2
                    guard length >= 0, length % 8 == 0 else {
                        input.seek(to: start)
                        throw .invalidLength
                    }

                    var blocks: [RFC_9293.`3`.`2`.SACK.Block] = []
                    blocks.reserveCapacity(length / 8)
                    for _ in 0..<(length / 8) {
                        blocks.append(
                            RFC_9293.`3`.`2`.SACK.Block(
                                leftEdge: RFC_9293.SequenceNumber(rawValue: try thirtyTwo()),
                                rightEdge: RFC_9293.SequenceNumber(rawValue: try thirtyTwo())
                            )
                        )
                    }
                    return .sack(blocks)

                case 8:
                    try expect(length: 10)
                    return .timestamps(value: try thirtyTwo(), echoReply: try thirtyTwo())

                case let kind:
                    let length = Int(try octet()) - 2
                    guard length >= 0 else {
                        input.seek(to: start)
                        throw .invalidLength
                    }

                    var data: [Byte] = []
                    data.reserveCapacity(length)
                    for _ in 0..<length {
                        data.append(Byte(bitPattern: try octet()))
                    }
                    return .unknown(kind: kind, data: data)
                }
            }

            public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
                RFC_9293.`3`.`2`.Option.serialize(output, into: &buffer)
            }
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }
#endif
