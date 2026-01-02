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

extension RFC_9293.SequenceNumber {
    /// Errors that can occur when parsing a SequenceNumber
    public enum Error: Swift.Error, Sendable, Equatable {
        case insufficientBytes
    }
}

extension RFC_9293.SequenceNumber.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes:
            return "SequenceNumber requires 4 bytes"
        }
    }
}
