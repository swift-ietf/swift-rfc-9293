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

extension RFC_9293.`3`.`1`.Header {
    /// Errors that can occur when parsing a TCP header
    public enum Error: Swift.Error, Sendable, Equatable {
        case insufficientBytes
        case dataOffsetTooSmall
        case dataOffsetTooLarge
    }
}

extension RFC_9293.`3`.`1`.Header.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes:
            return "TCP header requires at least 20 bytes"
        case .dataOffsetTooSmall:
            return "Data offset must be at least 5 (20 bytes)"
        case .dataOffsetTooLarge:
            return "Data offset cannot exceed 15 (60 bytes)"
        }
    }
}
