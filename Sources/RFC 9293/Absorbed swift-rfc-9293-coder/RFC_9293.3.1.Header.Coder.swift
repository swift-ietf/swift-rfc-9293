#if Coder
    import Binary
    public import Byte
    public import Coder
    public import Cursor
    import Parser
    import Serializer

    extension RFC_9293.`3`.`1`.Header {

        public struct Coder<Input: Cursor.`Protocol`<Byte, Never>, Buffer: RangeReplaceableCollection<Byte>>: Coding {

            public typealias Output = RFC_9293.`3`.`1`.Header

            public typealias Failure = RFC_9293.`3`.`1`.Header.Error

            public init() {}

            public borrowing func parse(_ input: inout Input) throws(Failure) -> Output {
                let start = input.checkpoint

                func sixteen() throws(Failure) -> UInt16 {
                    guard let high = input.next(), let low = input.next() else {
                        input.seek(to: start)
                        throw .insufficientBytes
                    }
                    return UInt16(high.bitPattern) << 8 | UInt16(low.bitPattern)
                }

                let sourcePort: RFC_9293.Port
                let destinationPort: RFC_9293.Port
                do throws(RFC_9293.Port.Error) {
                    sourcePort = try RFC_9293.Port.Coder<Input, Buffer>().parse(&input)
                    destinationPort = try RFC_9293.Port.Coder<Input, Buffer>().parse(&input)
                } catch {
                    input.seek(to: start)
                    throw .insufficientBytes
                }

                let sequenceNumber: RFC_9293.SequenceNumber
                let acknowledgmentNumber: RFC_9293.SequenceNumber
                do throws(RFC_9293.SequenceNumber.Error) {
                    sequenceNumber = try RFC_9293.SequenceNumber.Coder<Input, Buffer>().parse(&input)
                    acknowledgmentNumber = try RFC_9293.SequenceNumber.Coder<Input, Buffer>().parse(&input)
                } catch {
                    input.seek(to: start)
                    throw .insufficientBytes
                }

                let dataOffset: RFC_9293.`3`.`1`.DataOffset
                do throws(RFC_9293.`3`.`1`.DataOffset.Error) {
                    dataOffset = try RFC_9293.`3`.`1`.DataOffset.Coder<Input, Buffer>().parse(&input)
                } catch {
                    input.seek(to: start)
                    switch error {
                    case .insufficientBytes: throw .insufficientBytes
                    case .valueTooSmall, .notAligned: throw .dataOffsetTooSmall
                    case .valueTooLarge: throw .dataOffsetTooLarge
                    }
                }

                let flags: RFC_9293.`3`.`1`.Flags
                do throws(RFC_9293.`3`.`1`.Flags.Error) {
                    flags = try RFC_9293.`3`.`1`.Flags.Coder<Input, Buffer>().parse(&input)
                } catch {
                    input.seek(to: start)
                    throw .insufficientBytes
                }

                let window = try sixteen()
                let checksum = try sixteen()
                let urgentPointer = try sixteen()

                var options: [Byte] = []
                options.reserveCapacity(dataOffset.optionsLength)
                for _ in 0..<dataOffset.optionsLength {
                    guard let byte = input.next() else {
                        input.seek(to: start)
                        throw .insufficientBytes
                    }
                    options.append(byte)
                }

                return RFC_9293.`3`.`1`.Header(
                    sourcePort: sourcePort,
                    destinationPort: destinationPort,
                    sequenceNumber: sequenceNumber,
                    acknowledgmentNumber: acknowledgmentNumber,
                    dataOffset: dataOffset,
                    flags: flags,
                    window: window,
                    checksum: checksum,
                    urgentPointer: urgentPointer,
                    options: options
                )
            }

            public borrowing func serialize(_ output: Output, into buffer: inout Buffer) throws(Failure) {
                RFC_9293.`3`.`1`.Header.serialize(output, into: &buffer)
            }
        }

        public static var coder: Coder<ArraySlice<Byte>, [Byte]> { .init() }
    }
#endif
