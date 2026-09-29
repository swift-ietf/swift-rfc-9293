# RFC 9293

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)
[![CI](https://github.com/swift-ietf/swift-rfc-9293/workflows/CI/badge.svg)](https://github.com/swift-ietf/swift-rfc-9293/actions/workflows/ci.yml)

Swift implementation of RFC 9293: Transmission Control Protocol (TCP).

## Overview

This package is the pure domain model of TCP as defined in RFC 9293 (August 2022): the header fields of section 3.1 (ports, sequence numbers, data offset, control flags), the options of section 3.2, the connection states and send/receive sequence variables of section 3.3, the segment, and the transmission control block. Every field is a distinct type carrying its invariants, derived quantities and well-known values. It has no parser, serializer or formatter dependencies.

The wire forms live in the sibling package [swift-rfc-9293-coder](https://github.com/swift-ietf/swift-rfc-9293-coder): `<Type>.Coder` over a byte cursor for every field, option, header and segment, and `Binary.Serializable` conformances.

## Products

- `RFC 9293` — the domain model.
- `RFC 9293 Standard Library Integration` — `RFC_9293.3.1.Header(... options: [UInt8])` and `RFC_9293.Segment(header:data: [UInt8])` from unsigned bytes.
- `RFC 9293 Foundation Integration` — `Codable` for ports, sequence numbers, data offsets, control flags, connection states and selective-acknowledgment blocks (numbers code as their raw values, states as the name the specification uses).

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-9293.git", branch: "main")
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 9293", package: "swift-rfc-9293")
    ]
)
```

## Quick Start

```swift
import RFC_9293

let header = RFC_9293.`3`.`1`.Header(
    sourcePort: 12345,
    destinationPort: .https,
    sequenceNumber: .init(rawValue: 1000),
    acknowledgmentNumber: .init(rawValue: 2000),
    flags: .synAck,
    window: 32768,
    checksum: 0,
    urgentPointer: 0
)

header.dataOffset == .minimum   // true
header.description              // "TCP 12345 → 443 [ACK|SYN] seq=1000 ack=2000 win=32768"

let segment = RFC_9293.Segment(header: header)
segment.length                  // 20
segment.segmentLength           // 1 (the SYN consumes one sequence number)
segment.nextSequenceNumber      // 1001
```

### Ports and sequence numbers

```swift
let port = RFC_9293.Port(8080)
port.isRegistered               // true
RFC_9293.Port.http.rawValue     // 80

let earlier = RFC_9293.SequenceNumber(rawValue: UInt32.max - 100)
let later = RFC_9293.SequenceNumber(rawValue: 100)
earlier < later                 // true (comparison follows the wraparound)
later - earlier                 // 200
```

### Data offset and control flags

```swift
let offset = try RFC_9293.`3`.`1`.DataOffset(rawValue: 8)
offset.headerLength             // 32
offset.optionsLength            // 12

try RFC_9293.`3`.`1`.DataOffset(rawValue: 4)   // throws .valueTooSmall

let flags: RFC_9293.`3`.`1`.Flags = [.syn, .ack]
flags.rawValue                  // 0x12
flags.description               // "ACK|SYN"
```

### Options

```swift
RFC_9293.`3`.`2`.Option.maximumSegmentSize(1460).length   // 4
RFC_9293.`3`.`2`.Option.windowScale(7).kind                // 3

let block = RFC_9293.`3`.`2`.SACK.Block(
    leftEdge: .init(rawValue: 1000),
    rightEdge: .init(rawValue: 2000)
)
RFC_9293.`3`.`2`.Option.sack([block]).length               // 10
```

### Connection state and sequence variables

```swift
RFC_9293.`3`.`3`.State.established.canSendData     // true
RFC_9293.`3`.`3`.State.finWait1.isClosing          // true

var send = RFC_9293.`3`.`3`.Send.Variables(iss: .init(rawValue: 1000))
send.wnd = 100
send.nxt                        // 1001
send.usableWindow               // 99

let receive = RFC_9293.`3`.`3`.Receive.Variables(irs: .init(rawValue: 500), windowSize: 100)
receive.isInWindow(.init(rawValue: 550))   // true
```

### Transmission control block

```swift
import RFC_791

let block = RFC_9293.TCB(
    local: .init(address: RFC_791.IPv4.Address(rawValue: 0xC0A8_0101), port: 8080),
    remote: .init(address: RFC_791.IPv4.Address(rawValue: 0xC0A8_0102), port: .http),
    state: .established,
    send: .init(iss: .init(rawValue: 1000)),
    receive: nil,
    sendMSS: 1460,
    receiveMSS: 536
)

block.canSend                   // true
block.effectiveMSS              // 536
```

## Header format

```
 0                   1                   2                   3
 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1 2 3 4 5 6 7 8 9 0 1
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|          Source Port          |       Destination Port        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                        Sequence Number                        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                    Acknowledgment Number                      |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|  Data |       |C|E|U|A|P|R|S|F|                               |
| Offset| Rsrvd |W|C|R|C|S|S|Y|I|            Window             |
|       |       |R|E|G|K|H|T|N|N|                               |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|           Checksum            |         Urgent Pointer        |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
|                           [Options]                           |
+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+-+
```

| Field | Bits | Type |
|-------|------|------|
| Source Port | 16 | `RFC_9293.Port` |
| Destination Port | 16 | `RFC_9293.Port` |
| Sequence Number | 32 | `RFC_9293.SequenceNumber` |
| Acknowledgment Number | 32 | `RFC_9293.SequenceNumber` |
| Data Offset | 4 | `RFC_9293.3.1.DataOffset` |
| Control Bits | 8 | `RFC_9293.3.1.Flags` |
| Window | 16 | `UInt16` |
| Checksum | 16 | `UInt16` |
| Urgent Pointer | 16 | `UInt16` |
| Options | variable | `[Byte]` on the header, `RFC_9293.3.2.Option` once read |

## License

This package is licensed under the Apache License 2.0. See [LICENSE.md](LICENSE.md) for details.
