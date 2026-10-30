#if Coder
    public import Binary
    public import Byte

    extension RFC_9293.Port: Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ port: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: port.rawValue >> 8)))
            buffer.append(Byte(bitPattern: UInt8(truncatingIfNeeded: port.rawValue)))
        }
    }
#endif
