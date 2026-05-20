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

extension RFC_9293 {
    /// TCP Segment per RFC 9293
    ///
    /// A complete TCP segment consisting of a header and optional data payload.
    ///
    /// ## Structure
    ///
    /// Per RFC 9293 Section 3.1:
    /// - Header: 20-60 bytes
    /// - Data: variable length
    ///
    /// ## Example
    ///
    /// ```swift
    /// let segment = RFC_9293.Segment(
    ///     header: header,
    ///     data: Array("Hello".utf8)
    /// )
    /// ```
    public struct Segment: Hashable, Sendable {
        /// The TCP header
        public let header: `3`.`1`.Header

        /// The segment data payload (opaque byte-domain)
        public let data: [Byte]

        private init(__unchecked: Void, header: `3`.`1`.Header, data: [Byte]) {
            self.header = header
            self.data = data
        }

        /// Creates a TCP segment with the specified header and data
        public init(header: `3`.`1`.Header, data: [Byte]) {
            self.init(__unchecked: (), header: header, data: data)
        }

        // Stdlib-interop UInt8 forwarder lives in `RFC 9293 Standard Library
        // Integration` per [API-BYTE-007].
    }
}

// MARK: - Convenience Initializers

extension RFC_9293.Segment {
    /// Creates a TCP segment with no data (control segment)
    public init(header: RFC_9293.`3`.`1`.Header) {
        self.init(__unchecked: (), header: header, data: [])
    }
}

// MARK: - Computed Properties

extension RFC_9293.Segment {
    /// The total length of the segment in bytes
    public var length: Int {
        header.dataOffset.headerLength + data.count
    }

    /// The sequence number of the first data byte
    public var sequenceNumber: RFC_9293.SequenceNumber {
        header.sequenceNumber
    }

    /// The sequence number after the last byte in this segment
    ///
    /// For segments with SYN or FIN, this accounts for the phantom byte.
    public var nextSequenceNumber: RFC_9293.SequenceNumber {
        var seq = header.sequenceNumber + UInt32(data.count)

        // SYN and FIN consume a sequence number
        if header.flags.contains(.syn) { seq = seq + 1 }
        if header.flags.contains(.fin) { seq = seq + 1 }

        return seq
    }

    /// The segment length for sequence space purposes
    ///
    /// Per RFC 9293, SYN and FIN flags each consume one sequence number.
    public var segmentLength: UInt32 {
        var len = UInt32(data.count)
        if header.flags.contains(.syn) { len += 1 }
        if header.flags.contains(.fin) { len += 1 }
        return len
    }
}

// MARK: - Byte Parsing

extension RFC_9293.Segment {
    /// Creates a Segment from bytes
    public init<Bytes: Collection>(bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        let header: RFC_9293.`3`.`1`.Header
        do {
            header = try RFC_9293.`3`.`1`.Header(bytes: bytes)
        } catch let error as RFC_9293.`3`.`1`.Header.Error {
            switch error {
            case .insufficientBytes: throw Error.insufficientBytes
            case .dataOffsetTooSmall: throw Error.invalidDataOffset
            case .dataOffsetTooLarge: throw Error.invalidDataOffset
            }
        }

        let headerLength = header.dataOffset.headerLength
        let data = Array(bytes.dropFirst(headerLength))

        self.init(__unchecked: (), header: header, data: data)
    }
}

// MARK: - Binary.Serializable

extension RFC_9293.Segment: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ segment: RFC_9293.Segment,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        RFC_9293.`3`.`1`.Header.serialize(segment.header, into: &buffer)
        buffer.append(contentsOf: segment.data)
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.Segment: CustomStringConvertible {
    public var description: String {
        "\(header) len=\(data.count)"
    }
}
