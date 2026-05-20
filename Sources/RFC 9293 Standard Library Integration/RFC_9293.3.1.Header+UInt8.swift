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

// Stdlib-interop UInt8 forwarder for TCP header construction. Primary
// byte-domain API lives in `RFC 9293 3 Functional Specification`; this
// forwarder bridges stdlib callers carrying `[UInt8]` options (e.g.
// from parsed network buffers) via `.lazy.map(Byte.init)`. Per
// [API-BYTE-007] (byte-discipline skill).

public import RFC_9293_3_Functional_Specification
public import RFC_9293_Shared
internal import Byte_Primitives

extension RFC_9293.`3`.`1`.Header {
    /// Stdlib-interop forwarder: construction with `[UInt8]` options.
    @_disfavoredOverload
    public init(
        sourcePort: RFC_9293.Port,
        destinationPort: RFC_9293.Port,
        sequenceNumber: RFC_9293.SequenceNumber,
        acknowledgmentNumber: RFC_9293.SequenceNumber,
        dataOffset: RFC_9293.`3`.`1`.DataOffset,
        flags: RFC_9293.`3`.`1`.Flags,
        window: UInt16,
        checksum: UInt16,
        urgentPointer: UInt16,
        options: [UInt8]
    ) {
        self.init(
            sourcePort: sourcePort,
            destinationPort: destinationPort,
            sequenceNumber: sequenceNumber,
            acknowledgmentNumber: acknowledgmentNumber,
            dataOffset: dataOffset,
            flags: flags,
            window: window,
            checksum: checksum,
            urgentPointer: urgentPointer,
            options: [Byte](options.lazy.map(Byte.init))
        )
    }
}
