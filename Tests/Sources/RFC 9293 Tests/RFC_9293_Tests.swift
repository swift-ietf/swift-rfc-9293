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
import Testing

@Suite("RFC 9293 Tests")
struct RFC_9293_Tests {

    // MARK: - Port Tests

    @Suite("Port")
    struct PortTests {

        @Test("Port initialization")
        func portInit() {
            let port = RFC_9293.Port(8080)
            #expect(port.rawValue == 8080)
        }

        @Test("Well-known port constants")
        func wellKnownPorts() {
            #expect(RFC_9293.Port.http.rawValue == 80)
            #expect(RFC_9293.Port.https.rawValue == 443)
            #expect(RFC_9293.Port.ssh.rawValue == 22)
            #expect(RFC_9293.Port.ftp.rawValue == 21)
            #expect(RFC_9293.Port.smtp.rawValue == 25)
        }

        @Test("Port classification")
        func portClassification() {
            let wellKnown = RFC_9293.Port(80)
            let registered = RFC_9293.Port(8080)
            let dynamic = RFC_9293.Port(50000)

            #expect(wellKnown.isWellKnown)
            #expect(!wellKnown.isRegistered)
            #expect(!wellKnown.isDynamic)

            #expect(!registered.isWellKnown)
            #expect(registered.isRegistered)
            #expect(!registered.isDynamic)

            #expect(!dynamic.isWellKnown)
            #expect(!dynamic.isRegistered)
            #expect(dynamic.isDynamic)
        }

        @Test("Port byte parsing")
        func portByteParsing() throws {
            let bytes: [UInt8] = [0x1F, 0x90]  // 8080 in big-endian
            let port = try RFC_9293.Port(bytes: bytes)
            #expect(port.rawValue == 8080)
        }

        @Test("Port serialization")
        func portSerialization() {
            let port = RFC_9293.Port(8080)
            var buffer: [UInt8] = []
            RFC_9293.Port.serialize(port, into: &buffer)
            #expect(buffer == [0x1F, 0x90])
        }
    }

    // MARK: - Sequence Number Tests

    @Suite("SequenceNumber")
    struct SequenceNumberTests {

        @Test("Sequence number creation")
        func seqNumInit() {
            let seq = RFC_9293.SequenceNumber(rawValue: 12345)
            #expect(seq.rawValue == 12345)
        }

        @Test("Modular addition")
        func modularAddition() {
            let seq = RFC_9293.SequenceNumber(rawValue: 100)
            let next = seq + 50
            #expect(next.rawValue == 150)
        }

        @Test("Modular addition with wraparound")
        func modularAdditionWraparound() {
            let seq = RFC_9293.SequenceNumber(rawValue: UInt32.max - 10)
            let next = seq + 20
            #expect(next.rawValue == 9)  // Wraps around
        }

        @Test("Modular comparison - normal case")
        func modularComparisonNormal() {
            let a = RFC_9293.SequenceNumber(rawValue: 100)
            let b = RFC_9293.SequenceNumber(rawValue: 200)
            #expect(a < b)
            #expect(!(b < a))
        }

        @Test("Modular comparison - wraparound")
        func modularComparisonWraparound() {
            // When sequence numbers are close to wraparound
            let high = RFC_9293.SequenceNumber(rawValue: UInt32.max - 100)
            let low = RFC_9293.SequenceNumber(rawValue: 100)
            // The "low" value is actually ahead of "high" in sequence space
            #expect(high < low)
        }

        @Test("isWithin range check")
        func isWithinRange() {
            let left = RFC_9293.SequenceNumber(rawValue: 100)
            let right = RFC_9293.SequenceNumber(rawValue: 200)
            let inside = RFC_9293.SequenceNumber(rawValue: 150)
            let outside = RFC_9293.SequenceNumber(rawValue: 50)

            #expect(inside.isWithin(left: left, right: right))
            #expect(!outside.isWithin(left: left, right: right))
        }

        @Test("Sequence number byte parsing")
        func seqNumByteParsing() throws {
            let bytes: [UInt8] = [0x00, 0x01, 0x02, 0x03]  // 66051 in big-endian
            let seq = try RFC_9293.SequenceNumber(bytes: bytes)
            #expect(seq.rawValue == 0x0001_0203)
        }
    }

    // MARK: - State Tests

    @Suite("State")
    struct StateTests {

        @Test("State raw values")
        func stateRawValues() {
            #expect(RFC_9293.`3`.`3`.State.closed.rawValue == "CLOSED")
            #expect(RFC_9293.`3`.`3`.State.established.rawValue == "ESTABLISHED")
            #expect(RFC_9293.`3`.`3`.State.synSent.rawValue == "SYN-SENT")
        }

        @Test("canSendData states")
        func canSendDataStates() {
            #expect(RFC_9293.`3`.`3`.State.established.canSendData)
            #expect(RFC_9293.`3`.`3`.State.closeWait.canSendData)
            #expect(!RFC_9293.`3`.`3`.State.closed.canSendData)
            #expect(!RFC_9293.`3`.`3`.State.listen.canSendData)
        }

        @Test("canReceiveData states")
        func canReceiveDataStates() {
            #expect(RFC_9293.`3`.`3`.State.established.canReceiveData)
            #expect(RFC_9293.`3`.`3`.State.finWait1.canReceiveData)
            #expect(RFC_9293.`3`.`3`.State.finWait2.canReceiveData)
            #expect(!RFC_9293.`3`.`3`.State.closed.canReceiveData)
        }

        @Test("isSynchronized states")
        func isSynchronizedStates() {
            #expect(RFC_9293.`3`.`3`.State.established.isSynchronized)
            #expect(RFC_9293.`3`.`3`.State.finWait1.isSynchronized)
            #expect(!RFC_9293.`3`.`3`.State.closed.isSynchronized)
            #expect(!RFC_9293.`3`.`3`.State.synSent.isSynchronized)
        }

        @Test("isClosing states")
        func isClosingStates() {
            #expect(RFC_9293.`3`.`3`.State.finWait1.isClosing)
            #expect(RFC_9293.`3`.`3`.State.finWait2.isClosing)
            #expect(RFC_9293.`3`.`3`.State.timeWait.isClosing)
            #expect(!RFC_9293.`3`.`3`.State.established.isClosing)
        }
    }

    // MARK: - Flags Tests

    @Suite("Flags")
    struct FlagsTests {

        @Test("Individual flags")
        func individualFlags() {
            #expect(RFC_9293.`3`.`1`.Flags.fin.rawValue == 0x01)
            #expect(RFC_9293.`3`.`1`.Flags.syn.rawValue == 0x02)
            #expect(RFC_9293.`3`.`1`.Flags.rst.rawValue == 0x04)
            #expect(RFC_9293.`3`.`1`.Flags.psh.rawValue == 0x08)
            #expect(RFC_9293.`3`.`1`.Flags.ack.rawValue == 0x10)
            #expect(RFC_9293.`3`.`1`.Flags.urg.rawValue == 0x20)
        }

        @Test("Combined flags")
        func combinedFlags() {
            let synAck: RFC_9293.`3`.`1`.Flags = [.syn, .ack]
            #expect(synAck.contains(.syn))
            #expect(synAck.contains(.ack))
            #expect(!synAck.contains(.fin))
            #expect(synAck.rawValue == 0x12)
        }

        @Test("Common combinations")
        func commonCombinations() {
            #expect(RFC_9293.`3`.`1`.Flags.synAck == [.syn, .ack])
            #expect(RFC_9293.`3`.`1`.Flags.finAck == [.fin, .ack])
        }
    }

    // MARK: - DataOffset Tests

    @Suite("DataOffset")
    struct DataOffsetTests {

        @Test("Minimum offset")
        func minimumOffset() {
            let offset = RFC_9293.`3`.`1`.DataOffset.minimum
            #expect(offset.rawValue == 5)
            #expect(offset.headerLength == 20)
            #expect(offset.optionsLength == 0)
        }

        @Test("Maximum offset")
        func maximumOffset() {
            let offset = RFC_9293.`3`.`1`.DataOffset.maximum
            #expect(offset.rawValue == 15)
            #expect(offset.headerLength == 60)
            #expect(offset.optionsLength == 40)
        }

        @Test("Offset with options")
        func offsetWithOptions() throws {
            let offset = try RFC_9293.`3`.`1`.DataOffset(rawValue: 8)
            #expect(offset.headerLength == 32)
            #expect(offset.optionsLength == 12)
        }

        @Test("Invalid offset too small")
        func offsetTooSmall() {
            #expect(throws: RFC_9293.`3`.`1`.DataOffset.Error.self) {
                try RFC_9293.`3`.`1`.DataOffset(rawValue: 4)
            }
        }

        @Test("fromHeaderLength")
        func fromHeaderLength() throws {
            let offset = try RFC_9293.`3`.`1`.DataOffset.fromHeaderLength(28)
            #expect(offset.rawValue == 7)
        }
    }

    // MARK: - Header Tests

    @Suite("Header")
    struct HeaderTests {

        @Test("Header creation without options")
        func headerCreationNoOptions() {
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
            #expect(header.sourcePort.rawValue == 8080)
            #expect(header.destinationPort.rawValue == 80)
            #expect(header.flags.contains(.syn))
            #expect(header.dataOffset == .minimum)
            #expect(header.options.isEmpty)
        }

        @Test("Header byte parsing")
        func headerByteParsing() throws {
            // Construct a minimal 20-byte TCP header
            var bytes: [UInt8] = []

            // Source port: 8080 (0x1F90)
            bytes.append(contentsOf: [0x1F, 0x90])
            // Destination port: 80 (0x0050)
            bytes.append(contentsOf: [0x00, 0x50])
            // Sequence number: 12345
            bytes.append(contentsOf: [0x00, 0x00, 0x30, 0x39])
            // Ack number: 0
            bytes.append(contentsOf: [0x00, 0x00, 0x00, 0x00])
            // Data offset (5) + reserved (0) = 0x50, flags (SYN = 0x02)
            bytes.append(contentsOf: [0x50, 0x02])
            // Window: 65535
            bytes.append(contentsOf: [0xFF, 0xFF])
            // Checksum: 0
            bytes.append(contentsOf: [0x00, 0x00])
            // Urgent pointer: 0
            bytes.append(contentsOf: [0x00, 0x00])

            let header = try RFC_9293.`3`.`1`.Header(bytes: bytes)
            #expect(header.sourcePort.rawValue == 8080)
            #expect(header.destinationPort.rawValue == 80)
            #expect(header.sequenceNumber.rawValue == 12345)
            #expect(header.flags.contains(.syn))
            #expect(header.window == 65535)
        }

        @Test("Header serialization roundtrip")
        func headerRoundtrip() throws {
            let original = RFC_9293.`3`.`1`.Header(
                sourcePort: .init(12345),
                destinationPort: .https,
                sequenceNumber: .init(rawValue: 999999),
                acknowledgmentNumber: .init(rawValue: 888888),
                flags: .synAck,
                window: 32768,
                checksum: 0xABCD,
                urgentPointer: 0
            )
            var buffer: [UInt8] = []
            RFC_9293.`3`.`1`.Header.serialize(original, into: &buffer)

            let parsed = try RFC_9293.`3`.`1`.Header(bytes: buffer)
            #expect(parsed.sourcePort == original.sourcePort)
            #expect(parsed.destinationPort == original.destinationPort)
            #expect(parsed.sequenceNumber == original.sequenceNumber)
            #expect(parsed.acknowledgmentNumber == original.acknowledgmentNumber)
            #expect(parsed.flags == original.flags)
            #expect(parsed.window == original.window)
        }
    }

    // MARK: - Option Tests

    @Suite("Option")
    struct OptionTests {

        @Test("MSS option")
        func mssOption() {
            let option = RFC_9293.`3`.`2`.Option.maximumSegmentSize(1460)
            #expect(option.kind == 2)
            #expect(option.length == 4)
        }

        @Test("Window scale option")
        func windowScaleOption() {
            let option = RFC_9293.`3`.`2`.Option.windowScale(7)
            #expect(option.kind == 3)
            #expect(option.length == 3)
        }

        @Test("Timestamps option")
        func timestampsOption() {
            let option = RFC_9293.`3`.`2`.Option.timestamps(value: 12345, echoReply: 67890)
            #expect(option.kind == 8)
            #expect(option.length == 10)
        }

        @Test("Option parsing roundtrip")
        func optionRoundtrip() throws {
            let original = RFC_9293.`3`.`2`.Option.maximumSegmentSize(1460)
            var buffer: [UInt8] = []
            RFC_9293.`3`.`2`.Option.serialize(original, into: &buffer)

            let (parsed, consumed) = try RFC_9293.`3`.`2`.Option.parse(from: buffer)
            #expect(consumed == 4)
            if case .maximumSegmentSize(let mss) = parsed {
                #expect(mss == 1460)
            } else {
                Issue.record("Expected MSS option")
            }
        }
    }

    // MARK: - Constants Tests

    @Suite("Constants")
    struct ConstantsTests {

        @Test("Protocol number")
        func protocolNumber() {
            #expect(RFC_9293.protocolNumber == 6)
        }

        @Test("Header sizes")
        func headerSizes() {
            #expect(RFC_9293.minimumHeaderSize == 20)
            #expect(RFC_9293.maximumHeaderSize == 60)
        }

        @Test("Default MSS values")
        func defaultMSSValues() {
            #expect(RFC_9293.defaultMSSIPv4 == 536)
            #expect(RFC_9293.defaultMSSIPv6 == 1220)
        }

        @Test("TIME-WAIT duration")
        func timeWaitDuration() {
            #expect(RFC_9293.mslSeconds == 120)
            #expect(RFC_9293.timeWaitDurationSeconds == 240)
        }
    }

    // MARK: - TCB Tests

    @Suite("TCB")
    struct TCBTests {

        @Test("TCB socket creation")
        func tcbSocketCreation() {
            let socket = RFC_9293.TCB.Socket(
                address: RFC_791.IPv4.Address(192, 168, 1, 1),
                port: .init(8080)
            )
            #expect(socket.port.rawValue == 8080)
        }

        @Test("TCB computed properties")
        func tcbComputedProperties() throws {
            let sendVars = RFC_9293.`3`.`3`.Send.Variables(iss: .init(rawValue: 1000))

            let tcb = RFC_9293.TCB(
                local: .init(address: RFC_791.IPv4.Address(192, 168, 1, 1), port: .init(8080)),
                remote: .init(address: RFC_791.IPv4.Address(192, 168, 1, 2), port: .http),
                state: .established,
                send: sendVars,
                receive: nil
            )

            #expect(tcb.isSynchronized)
            #expect(tcb.canSend)
            #expect(tcb.canReceive)
        }
    }
}
