#if Coder
    public import Binary
    public import Byte

    extension RFC_9293.SequenceNumber: Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ sequenceNumber: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: sequenceNumber.rawValue >> 24)))
            buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: sequenceNumber.rawValue >> 16)))
            buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: sequenceNumber.rawValue >> 8)))
            buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: sequenceNumber.rawValue)))
        }
    }
#endif
