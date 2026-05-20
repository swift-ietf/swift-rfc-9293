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

import RFC_9293
import RFC_9293_Standard_Library_Integration
import Testing

@Suite("RFC 9293 UInt8 forwarders")
struct RFC_9293_UInt8_Forwarder_Tests {

    @Test
    func `Segment forwarder accepts [UInt8] data`() {
        let header = RFC_9293.`3`.`1`.Header(
            sourcePort: .init(8080),
            destinationPort: .http,
            sequenceNumber: .init(rawValue: 12345),
            acknowledgmentNumber: .init(rawValue: 0),
            flags: [.syn],
            window: 65535,
            checksum: 0,
            urgentPointer: 0
        )
        let uint8Data: [UInt8] = Array("Hello".utf8)
        let segment = RFC_9293.Segment(header: header, data: uint8Data)
        #expect(segment.data.count == 5)
        #expect(segment.data == [Byte](uint8Data.lazy.map(Byte.init)))
    }

    @Test
    func `Header forwarder accepts [UInt8] options`() throws {
        let dataOffset = try RFC_9293.`3`.`1`.DataOffset(rawValue: 6)
        let uint8Options: [UInt8] = [0x02, 0x04, 0x05, 0xB4]  // MSS option bytes
        let header = RFC_9293.`3`.`1`.Header(
            sourcePort: .init(8080),
            destinationPort: .http,
            sequenceNumber: .init(rawValue: 12345),
            acknowledgmentNumber: .init(rawValue: 0),
            dataOffset: dataOffset,
            flags: [.syn],
            window: 65535,
            checksum: 0,
            urgentPointer: 0,
            options: uint8Options
        )
        #expect(header.options.count == 4)
        #expect(header.options == [Byte](uint8Options.lazy.map(Byte.init)))
    }
}
