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

public import Standards

extension RFC_9293.`3`.`2` {
    /// TCP Option per RFC 9293 Section 3.2
    ///
    /// TCP options provide additional capabilities beyond the basic header.
    /// Options are variable-length and padded to 32-bit boundaries.
    ///
    /// ## Option Kinds
    ///
    /// Per RFC 9293 Section 3.2:
    /// - Kind 0: End of Option List
    /// - Kind 1: No-Operation
    /// - Kind 2: Maximum Segment Size
    /// - Kind 3: Window Scale (RFC 7323)
    /// - Kind 4: SACK Permitted (RFC 2018)
    /// - Kind 5: SACK (RFC 2018)
    /// - Kind 8: Timestamps (RFC 7323)
    ///
    /// ## Example
    ///
    /// ```swift
    /// let mss = RFC_9293.`3`.`2`.Option.maximumSegmentSize(1460)
    /// let windowScale = RFC_9293.`3`.`2`.Option.windowScale(7)
    /// ```
    public enum Option: Hashable, Sendable {
        /// End of Option List (Kind 0)
        case endOfOptionList

        /// No-Operation, used for padding (Kind 1)
        case noOperation

        /// Maximum Segment Size (Kind 2)
        case maximumSegmentSize(UInt16)

        /// Window Scale factor (Kind 3, RFC 7323)
        case windowScale(UInt8)

        /// SACK Permitted (Kind 4, RFC 2018)
        case sackPermitted

        /// Selective Acknowledgment (Kind 5, RFC 2018)
        case sack([SACK.Block])

        /// Timestamps (Kind 8, RFC 7323)
        case timestamps(value: UInt32, echoReply: UInt32)

        /// Unknown or unsupported option
        case unknown(kind: UInt8, data: [UInt8])
    }
}

// MARK: - SACK

extension RFC_9293.`3`.`2` {
    /// Selective Acknowledgment namespace per RFC 2018
    public enum SACK {}
}

extension RFC_9293.`3`.`2`.SACK {
    /// A SACK block representing a contiguous range of received data
    public struct Block: Hashable, Sendable, Codable {
        /// Left edge of the block (first sequence number)
        public let leftEdge: RFC_9293.SequenceNumber

        /// Right edge of the block (sequence number after last)
        public let rightEdge: RFC_9293.SequenceNumber

        public init(leftEdge: RFC_9293.SequenceNumber, rightEdge: RFC_9293.SequenceNumber) {
            self.leftEdge = leftEdge
            self.rightEdge = rightEdge
        }
    }
}

// MARK: - Option Kind Constants

extension RFC_9293.`3`.`2`.Option {
    /// Option kind values per RFC 9293 Section 3.2
    public enum Kind: UInt8, Hashable, Sendable {
        case endOfOptionList = 0
        case noOperation = 1
        case maximumSegmentSize = 2
        case windowScale = 3
        case sackPermitted = 4
        case sack = 5
        case timestamps = 8
    }
}

// MARK: - Computed Properties

extension RFC_9293.`3`.`2`.Option {
    /// The kind value for this option
    public var kind: UInt8 {
        switch self {
        case .endOfOptionList: return 0
        case .noOperation: return 1
        case .maximumSegmentSize: return 2
        case .windowScale: return 3
        case .sackPermitted: return 4
        case .sack: return 5
        case .timestamps: return 8
        case .unknown(let k, _): return k
        }
    }

    /// The total length of this option in bytes
    public var length: Int {
        switch self {
        case .endOfOptionList: return 1
        case .noOperation: return 1
        case .maximumSegmentSize: return 4
        case .windowScale: return 3
        case .sackPermitted: return 2
        case .sack(let blocks): return 2 + (blocks.count * 8)
        case .timestamps: return 10
        case .unknown(_, let data): return 2 + data.count
        }
    }
}

// MARK: - Byte Parsing

extension RFC_9293.`3`.`2`.Option {
    /// Parses a single option from bytes, returning the option and bytes consumed
    public static func parse<Bytes: Collection>(
        from bytes: Bytes
    ) throws(Error) -> (option: Self, consumed: Int)
    where Bytes.Element == UInt8 {
        var iterator = bytes.makeIterator()

        guard let kind = iterator.next() else {
            throw .insufficientBytes
        }

        switch kind {
        case 0:
            return (.endOfOptionList, 1)

        case 1:
            return (.noOperation, 1)

        case 2:
            guard let length = iterator.next(), length == 4 else {
                throw .invalidLength
            }
            guard let hi = iterator.next(), let lo = iterator.next() else {
                throw .insufficientBytes
            }
            let mss = UInt16(hi) << 8 | UInt16(lo)
            return (.maximumSegmentSize(mss), 4)

        case 3:
            guard let length = iterator.next(), length == 3 else {
                throw .invalidLength
            }
            guard let shift = iterator.next() else {
                throw .insufficientBytes
            }
            return (.windowScale(shift), 3)

        case 4:
            guard let length = iterator.next(), length == 2 else {
                throw .invalidLength
            }
            return (.sackPermitted, 2)

        case 5:
            guard let length = iterator.next() else {
                throw .insufficientBytes
            }
            let dataLength = Int(length) - 2
            guard dataLength >= 0, dataLength % 8 == 0 else {
                throw .invalidLength
            }

            var blocks: [RFC_9293.`3`.`2`.SACK.Block] = []
            let blockCount = dataLength / 8
            blocks.reserveCapacity(blockCount)

            for _ in 0..<blockCount {
                guard let l0 = iterator.next(), let l1 = iterator.next(),
                    let l2 = iterator.next(), let l3 = iterator.next(),
                    let r0 = iterator.next(), let r1 = iterator.next(),
                    let r2 = iterator.next(), let r3 = iterator.next()
                else {
                    throw .insufficientBytes
                }
                let left = UInt32(l0) << 24 | UInt32(l1) << 16 | UInt32(l2) << 8 | UInt32(l3)
                let right = UInt32(r0) << 24 | UInt32(r1) << 16 | UInt32(r2) << 8 | UInt32(r3)
                blocks.append(
                    RFC_9293.`3`.`2`.SACK.Block(
                        leftEdge: RFC_9293.SequenceNumber(rawValue: left),
                        rightEdge: RFC_9293.SequenceNumber(rawValue: right)
                    )
                )
            }
            return (.sack(blocks), Int(length))

        case 8:
            guard let length = iterator.next(), length == 10 else {
                throw .invalidLength
            }
            guard let v0 = iterator.next(), let v1 = iterator.next(),
                let v2 = iterator.next(), let v3 = iterator.next(),
                let e0 = iterator.next(), let e1 = iterator.next(),
                let e2 = iterator.next(), let e3 = iterator.next()
            else {
                throw .insufficientBytes
            }
            let value = UInt32(v0) << 24 | UInt32(v1) << 16 | UInt32(v2) << 8 | UInt32(v3)
            let echo = UInt32(e0) << 24 | UInt32(e1) << 16 | UInt32(e2) << 8 | UInt32(e3)
            return (.timestamps(value: value, echoReply: echo), 10)

        default:
            guard let length = iterator.next() else {
                throw .insufficientBytes
            }
            let dataLength = Int(length) - 2
            guard dataLength >= 0 else {
                throw .invalidLength
            }

            var data: [UInt8] = []
            data.reserveCapacity(dataLength)
            for _ in 0..<dataLength {
                guard let byte = iterator.next() else {
                    throw .insufficientBytes
                }
                data.append(byte)
            }
            return (.unknown(kind: kind, data: data), Int(length))
        }
    }

    /// Parses all options from a byte buffer
    public static func parseAll<Bytes: Collection>(
        from bytes: Bytes
    ) throws(Error) -> [Self]
    where Bytes.Element == UInt8 {
        var options: [Self] = []
        var remaining = Array(bytes)

        while !remaining.isEmpty {
            let (option, consumed) = try parse(from: remaining)
            options.append(option)

            if case .endOfOptionList = option {
                break
            }

            remaining.removeFirst(consumed)
        }

        return options
    }
}

// MARK: - Binary.Serializable

extension RFC_9293.`3`.`2`.Option: Binary.Serializable {
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ option: RFC_9293.`3`.`2`.Option,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        switch option {
        case .endOfOptionList:
            buffer.append(0)

        case .noOperation:
            buffer.append(1)

        case .maximumSegmentSize(let mss):
            buffer.append(2)
            buffer.append(4)
            buffer.append(contentsOf: mss.bytes(endianness: .big))

        case .windowScale(let shift):
            buffer.append(3)
            buffer.append(3)
            buffer.append(shift)

        case .sackPermitted:
            buffer.append(4)
            buffer.append(2)

        case .sack(let blocks):
            buffer.append(5)
            buffer.append(UInt8(2 + blocks.count * 8))
            for block in blocks {
                buffer.append(contentsOf: block.leftEdge.rawValue.bytes(endianness: .big))
                buffer.append(contentsOf: block.rightEdge.rawValue.bytes(endianness: .big))
            }

        case .timestamps(let value, let echoReply):
            buffer.append(8)
            buffer.append(10)
            buffer.append(contentsOf: value.bytes(endianness: .big))
            buffer.append(contentsOf: echoReply.bytes(endianness: .big))

        case .unknown(let kind, let data):
            buffer.append(kind)
            buffer.append(UInt8(2 + data.count))
            buffer.append(contentsOf: data)
        }
    }
}

// MARK: - CustomStringConvertible

extension RFC_9293.`3`.`2`.Option: CustomStringConvertible {
    public var description: String {
        switch self {
        case .endOfOptionList:
            return "EOL"
        case .noOperation:
            return "NOP"
        case .maximumSegmentSize(let mss):
            return "MSS=\(mss)"
        case .windowScale(let shift):
            return "WS=\(shift)"
        case .sackPermitted:
            return "SACK-OK"
        case .sack(let blocks):
            let ranges = blocks.map { "\($0.leftEdge)-\($0.rightEdge)" }
            return "SACK[\(ranges.joined(separator: ","))]"
        case .timestamps(let value, let echo):
            return "TS=\(value)/\(echo)"
        case .unknown(let kind, _):
            return "OPT(\(kind))"
        }
    }
}
