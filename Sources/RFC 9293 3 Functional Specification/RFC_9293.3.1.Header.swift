// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

public import Standard_Library_Extensions

extension RFC_9293.`3`.`1` {
    /// TCP Header per RFC 9293 Section 3.1
    ///
    /// The TCP header is at least 20 bytes and can extend to 60 bytes with options.
    ///
    /// ## Binary Format
    ///
    /// ```
    ///  0                   1                   2                   3
    ///  0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |          Source Port          |       Destination Port        |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |                        Sequence Number                        |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |                    Acknowledgment Number                      |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |  Data |       |C|E|U|A|P|R|S|F|                               |
    /// | Offset| Rsrvd |W|C|R|C|S|S|Y|I|            Window             |
    /// |       |       |R|E|G|K|H|T|N|N|                               |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |           Checksum            |         Urgent Pointer        |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// |                           [Options]                           |
    /// +-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
    /// ```
    ///
    /// ## Example
    ///
    /// ```swift
    /// let header = RFC_9293.`3`.`1`.Header(
    ///     sourcePort: .init(8080),
    ///     destinationPort: .http,
    ///     sequenceNumber: .init(rawValue: 12345),
    ///     acknowledgmentNumber: .init(rawValue: 0),
    ///     dataOffset: .minimum,
    ///     flags: [.syn],
    ///     window: 65535,
    ///     checksum: 0,
    ///     urgentPointer: 0,
    ///     options: []
    /// )
    /// ```
    public struct Header: Hashable, Sendable {
        /// Source port number
        public let sourcePort: RFC_9293.Port

        /// Destination port number
        public let destinationPort: RFC_9293.Port

        /// Sequence number
        public let sequenceNumber: RFC_9293.SequenceNumber

        /// Acknowledgment number (significant only if ACK flag is set)
        public let acknowledgmentNumber: RFC_9293.SequenceNumber

        /// Data offset (header length in 32-bit words)
        public let dataOffset: DataOffset

        /// Control flags
        public let flags: Flags

        /// Window size (number of bytes sender is willing to receive)
        public let window: UInt16

        /// Checksum (computed over pseudo-header, header, and data)
        public let checksum: UInt16

        /// Urgent pointer (offset from sequence number, significant only if URG flag is set)
        public let urgentPointer: UInt16

        /// Options (variable length, up to 40 bytes, opaque byte-domain payload)
        public let options: [Byte]

        private init(
            __unchecked: Void,
            sourcePort: RFC_9293.Port,
            destinationPort: RFC_9293.Port,
            sequenceNumber: RFC_9293.SequenceNumber,
            acknowledgmentNumber: RFC_9293.SequenceNumber,
            dataOffset: DataOffset,
            flags: Flags,
            window: UInt16,
            checksum: UInt16,
            urgentPointer: UInt16,
            options: [Byte]
        ) {
            self.sourcePort = sourcePort
            self.destinationPort = destinationPort
            self.sequenceNumber = sequenceNumber
            self.acknowledgmentNumber = acknowledgmentNumber
            self.dataOffset = dataOffset
            self.flags = flags
            self.window = window
            self.checksum = checksum
            self.urgentPointer = urgentPointer
            self.options = options
        }

        /// Creates a TCP header with the specified fields
        public init(
            sourcePort: RFC_9293.Port,
            destinationPort: RFC_9293.Port,
            sequenceNumber: RFC_9293.SequenceNumber,
            acknowledgmentNumber: RFC_9293.SequenceNumber,
            dataOffset: DataOffset,
            flags: Flags,
            window: UInt16,
            checksum: UInt16,
            urgentPointer: UInt16,
            options: [Byte]
        ) {
            self.init(
                __unchecked: (),
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

        // Stdlib-interop UInt8 forwarder lives in `RFC 9293 Standard Library
        // Integration` per [API-BYTE-007].
    }
}

// MARK: - Convenience Initializers

extension RFC_9293.`3`.`1`.Header {
    /// Creates a TCP header with no options (20-byte header)
    public init(
        sourcePort: RFC_9293.Port,
        destinationPort: RFC_9293.Port,
        sequenceNumber: RFC_9293.SequenceNumber,
        acknowledgmentNumber: RFC_9293.SequenceNumber,
        flags: RFC_9293.`3`.`1`.Flags,
        window: UInt16,
        checksum: UInt16,
        urgentPointer: UInt16
    ) {
        self.init(
            __unchecked: (),
            sourcePort: sourcePort,
            destinationPort: destinationPort,
            sequenceNumber: sequenceNumber,
            acknowledgmentNumber: acknowledgmentNumber,
            dataOffset: .minimum,
            flags: flags,
            window: window,
            checksum: checksum,
            urgentPointer: urgentPointer,
            options: []
        )
    }
}

// MARK: - Byte Parsing

extension RFC_9293.`3`.`1`.Header {
    /// Creates a Header from bytes (big-endian)
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard bytes.count >= 20 else { throw .insufficientBytes }

        var iterator = bytes.makeIterator()

        // Internal arithmetic-domain UInt8 byte stream; bridge from Byte at
        // the conformance boundary via .underlying.
        func next() -> UInt8 {
            iterator.next()!.underlying
        }

        // Source port (bytes 0-1)
        let srcHi = next()
        let srcLo = next()
        let srcPort = RFC_9293.Port(UInt16(srcHi) << 8 | UInt16(srcLo))

        // Destination port (bytes 2-3)
        let dstHi = next()
        let dstLo = next()
        let dstPort = RFC_9293.Port(UInt16(dstHi) << 8 | UInt16(dstLo))

        // Sequence number (bytes 4-7)
        let seq0 = next()
        let seq1 = next()
        let seq2 = next()
        let seq3 = next()
        let seqValue = UInt32(seq0) << 24 | UInt32(seq1) << 16 | UInt32(seq2) << 8 | UInt32(seq3)
        let seqNum = RFC_9293.SequenceNumber(rawValue: seqValue)

        // Acknowledgment number (bytes 8-11)
        let ack0 = next()
        let ack1 = next()
        let ack2 = next()
        let ack3 = next()
        let ackValue = UInt32(ack0) << 24 | UInt32(ack1) << 16 | UInt32(ack2) << 8 | UInt32(ack3)
        let ackNum = RFC_9293.SequenceNumber(rawValue: ackValue)

        // Data offset and reserved (byte 12)
        let offsetByte = next()
        let offsetValue = offsetByte >> 4

        let dataOffset: RFC_9293.`3`.`1`.DataOffset
        do {
            dataOffset = try RFC_9293.`3`.`1`.DataOffset(rawValue: offsetValue)
        } catch let error as RFC_9293.`3`.`1`.DataOffset.Error {
            switch error {
            case .valueTooSmall: throw Error.dataOffsetTooSmall
            case .valueTooLarge: throw Error.dataOffsetTooLarge
            case .notAligned: throw Error.dataOffsetTooSmall  // Won't happen here
            }
        }

        // Flags (byte 13)
        let flagsByte = next()
        let flags = RFC_9293.`3`.`1`.Flags(rawValue: flagsByte)

        // Window (bytes 14-15)
        let winHi = next()
        let winLo = next()
        let window = UInt16(winHi) << 8 | UInt16(winLo)

        // Checksum (bytes 16-17)
        let csHi = next()
        let csLo = next()
        let checksum = UInt16(csHi) << 8 | UInt16(csLo)

        // Urgent pointer (bytes 18-19)
        let urgHi = next()
        let urgLo = next()
        let urgentPointer = UInt16(urgHi) << 8 | UInt16(urgLo)

        // Options (remaining bytes up to header length). Opaque byte-domain
        // storage as [Byte].
        let optionsLength = dataOffset.optionsLength
        guard bytes.count >= 20 + optionsLength else { throw .insufficientBytes }

        var options: [Byte] = []
        options.reserveCapacity(optionsLength)
        for _ in 0..<optionsLength {
            options.append(Byte(next()))
        }

        self.init(
            __unchecked: (),
            sourcePort: srcPort,
            destinationPort: dstPort,
            sequenceNumber: seqNum,
            acknowledgmentNumber: ackNum,
            dataOffset: dataOffset,
            flags: flags,
            window: window,
            checksum: checksum,
            urgentPointer: urgentPointer,
            options: options
        )
    }
}

// MARK: - Binary.Serializable

extension RFC_9293.`3`.`1`.Header: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ header: RFC_9293.`3`.`1`.Header,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        // Source port
        buffer.append(contentsOf: header.sourcePort.rawValue.bytes(endianness: .big))

        // Destination port
        buffer.append(contentsOf: header.destinationPort.rawValue.bytes(endianness: .big))

        // Sequence number
        buffer.append(contentsOf: header.sequenceNumber.rawValue.bytes(endianness: .big))

        // Acknowledgment number
        buffer.append(contentsOf: header.acknowledgmentNumber.rawValue.bytes(endianness: .big))

        // Data offset (4 bits) + reserved (4 bits). DataOffset.rawValue stays
        // UInt8 (arithmetic-domain × 4 multiplier); bridge via Byte().
        buffer.append(Byte(header.dataOffset.rawValue << 4))

        // Flags (stays UInt8 per OptionSet RawValue: FixedWidthInteger).
        buffer.append(Byte(header.flags.rawValue))

        // Window
        buffer.append(contentsOf: header.window.bytes(endianness: .big))

        // Checksum
        buffer.append(contentsOf: header.checksum.bytes(endianness: .big))

        // Urgent pointer
        buffer.append(contentsOf: header.urgentPointer.bytes(endianness: .big))

        // Options (opaque byte-domain payload, already [Byte])
        buffer.append(contentsOf: header.options)
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.`3`.`1`.Header: CustomStringConvertible {
    public var description: String {
        "TCP \(sourcePort) → \(destinationPort) [\(flags)] seq=\(sequenceNumber) ack=\(acknowledgmentNumber) win=\(window)"
    }
}
