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

extension RFC_9293.`3`.`2`.Option {
    /// Errors that can occur when parsing TCP options
    public enum Error: Swift.Error, Sendable, Equatable {
        case insufficientBytes
        case invalidLength
    }
}

extension RFC_9293.`3`.`2`.Option.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .insufficientBytes:
            return "Not enough bytes to parse TCP option"
        case .invalidLength:
            return "Invalid option length"
        }
    }
}
