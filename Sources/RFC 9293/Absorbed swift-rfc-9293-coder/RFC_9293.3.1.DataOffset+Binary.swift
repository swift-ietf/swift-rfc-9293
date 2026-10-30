#if Coder
    public import Binary
    public import Byte

    extension RFC_9293.`3`.`1`.DataOffset: Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ offset: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            buffer.append(Byte(bitPattern: offset.rawValue << 4))
        }
    }
#endif
