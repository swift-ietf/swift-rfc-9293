#if Coder
    import Binary
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension RFC_9293.SequenceNumber {

        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

            public typealias Output = RFC_9293.SequenceNumber

            public typealias Failure = RFC_9293.SequenceNumber.Error

            public init() {}

            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let start = input.checkpoint
                var value: UInt32 = 0
                for _ in 0..<4 {
                    guard let byte = input.next() else {
                        input.seek(to: start)
                        throw .insufficientBytes
                    }
                    value = value << 8 | UInt32(byte.bitPattern)
                }
                return RFC_9293.SequenceNumber(rawValue: value)
            }

            public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
                RFC_9293.SequenceNumber.serialize(output, into: &buffer)
            }
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }
#endif
