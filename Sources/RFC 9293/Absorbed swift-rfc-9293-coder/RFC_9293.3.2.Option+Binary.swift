#if Coder
    public import Binary
    public import Byte

    extension RFC_9293.`3`.`2`.Option: Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ option: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            switch option {
            case .endOfOptionList:
                buffer.append(Byte(bitPattern: 0))

            case .noOperation:
                buffer.append(Byte(bitPattern: 1))

            case .maximumSegmentSize(let maximumSegmentSize):
                buffer.append(Byte(bitPattern: 2))
                buffer.append(Byte(bitPattern: 4))
                buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: maximumSegmentSize >> 8)))
                buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: maximumSegmentSize)))

            case .windowScale(let shift):
                buffer.append(Byte(bitPattern: 3))
                buffer.append(Byte(bitPattern: 3))
                buffer.append(Byte(bitPattern: shift))

            case .sackPermitted:
                buffer.append(Byte(bitPattern: 4))
                buffer.append(Byte(bitPattern: 2))

            case .sack(let blocks):
                buffer.append(Byte(bitPattern: 5))
                buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: 2 + blocks.count * 8)))
                for block in blocks {
                    RFC_9293.SequenceNumber.serialize(block.leftEdge, into: &buffer)
                    RFC_9293.SequenceNumber.serialize(block.rightEdge, into: &buffer)
                }

            case .timestamps(let value, let echoReply):
                buffer.append(Byte(bitPattern: 8))
                buffer.append(Byte(bitPattern: 10))
                RFC_9293.SequenceNumber.serialize(.init(rawValue: value), into: &buffer)
                RFC_9293.SequenceNumber.serialize(.init(rawValue: echoReply), into: &buffer)

            case .unknown(let kind, let data):
                buffer.append(Byte(bitPattern: kind))
                buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: 2 + data.count)))
                buffer.append(contentsOf: data)
            }
        }
    }
#endif
