#if Coder
    public import Binary
    public import Byte

    extension RFC_9293.`3`.`1`.Flags: Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ flags: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            buffer.append(Byte(bitPattern: flags.rawValue))
        }
    }
#endif
