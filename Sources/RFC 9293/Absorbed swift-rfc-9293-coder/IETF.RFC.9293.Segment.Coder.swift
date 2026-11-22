#if Coder
    import Binary
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension IETF.RFC.`9293`.Segment {

        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

            public typealias Output = IETF.RFC.`9293`.Segment

            public typealias Failure = IETF.RFC.`9293`.Segment.Error

            public init() {}

            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let start = input.checkpoint

                let header: IETF.RFC.`9293`.`3`.`1`.Header
                do throws(IETF.RFC.`9293`.`3`.`1`.Header.Error) {
                    header = try IETF.RFC.`9293`.`3`.`1`.Header.Coder<Input, Buffer>().parse(&input)
                } catch {
                    input.seek(to: start)
                    switch error {
                    case .insufficientBytes: throw .insufficientBytes
                    case .dataOffsetTooSmall, .dataOffsetTooLarge, .optionsTooLong: throw .invalidDataOffset
                    }
                }

                var data: [Byte] = []
                while let byte = input.next() {
                    data.append(byte)
                }

                return IETF.RFC.`9293`.Segment(header: header, data: data)
            }

            public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
                IETF.RFC.`9293`.Segment.serialize(output, into: &buffer)
            }
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }
#endif
