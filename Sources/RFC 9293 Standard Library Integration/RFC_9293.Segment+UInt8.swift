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

// Stdlib-interop UInt8 forwarder for TCP segment construction. Primary
// byte-domain API lives in `RFC 9293`; this forwarder bridges stdlib callers
// carrying `[UInt8]` (e.g. network buffers, file-read frames) via
// `.lazy.map(Byte.init)`. Per [API-BYTE-007] (byte-discipline skill).

public import RFC_9293
internal import Byte_Primitives

extension RFC_9293.Segment {
    /// Stdlib-interop forwarder: construction from `[UInt8]` data.
    @_disfavoredOverload
    public init(header: RFC_9293.`3`.`1`.Header, data: [UInt8]) {
        self.init(header: header, data: [Byte](data.lazy.map(Byte.init)))
    }
}
