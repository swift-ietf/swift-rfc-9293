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

extension RFC_9293.`3`.`1`.DataOffset {
    /// Errors that can occur when parsing a DataOffset
    public enum Error: Swift.Error, Sendable, Equatable {
        case valueTooSmall
        case valueTooLarge
        case notAligned
    }
}

extension RFC_9293.`3`.`1`.DataOffset.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .valueTooSmall:
            return "DataOffset must be at least 5 (20 bytes)"
        case .valueTooLarge:
            return "DataOffset cannot exceed 15 (60 bytes)"
        case .notAligned:
            return "Header length must be a multiple of 4 bytes"
        }
    }
}
