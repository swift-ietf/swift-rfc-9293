#if Coder
    public import Binary
    public import Byte

    extension IETF.RFC.`9293`.Segment: Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ segment: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            IETF.RFC.`9293`.`3`.`1`.Header.serialize(segment.header, into: &buffer)
            buffer.append(contentsOf: segment.data)
        }
    }
#endif
